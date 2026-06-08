#!/usr/bin/env python3
"""
Generates PassportQuest.xcodeproj/project.pbxproj by scanning the
PassportQuest/ source tree. Keeping generation in a script guarantees the
file references, build phases and group tree stay consistent with the files
that actually exist on disk.

Run from the repo root:  python3 tools/generate_pbxproj.py
"""

import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
APP_DIR = "PassportQuest"
PROJECT_NAME = "PassportQuest"
# NOTE: change this to your own reverse-DNS identifier before submitting to the
# App Store (it must be unique to your developer account; "com.example.*" is
# rejected by Apple). Then re-run this script to regenerate the project.
BUNDLE_ID = "com.mdgonsalvez.passportquest"

# Deterministic 24-hex-char identifiers.
_counter = 0
def uid():
    global _counter
    _counter += 1
    return f"PQ0000000000{_counter:012X}"

def is_hidden(name):
    return name.startswith(".")

# ---------------------------------------------------------------------------
# Walk the source tree and collect entries.
# ---------------------------------------------------------------------------

swift_files = []     # (abs_path, rel_path_from_app_dir)
asset_catalog = None  # rel path
privacy_manifest = None
localizable_dirs = []  # list of (lang, abs path to Localizable.strings)

for dirpath, dirnames, filenames in os.walk(os.path.join(ROOT, APP_DIR)):
    dirnames[:] = sorted(d for d in dirnames if not is_hidden(d))
    rel_dir = os.path.relpath(dirpath, os.path.join(ROOT, APP_DIR))
    # Treat .xcassets as a single folder reference, do not descend.
    pruned = []
    for d in list(dirnames):
        if d.endswith(".xcassets"):
            rel = os.path.normpath(os.path.join(rel_dir, d)) if rel_dir != "." else d
            asset_catalog = rel
            pruned.append(d)
        if d.endswith(".lproj"):
            lang = d[:-len(".lproj")]
            strings_path = os.path.join(dirpath, d, "Localizable.strings")
            if os.path.exists(strings_path):
                localizable_dirs.append((lang, strings_path))
            pruned.append(d)
    for d in pruned:
        dirnames.remove(d)

    for f in sorted(filenames):
        if is_hidden(f):
            continue
        abs_path = os.path.join(dirpath, f)
        rel = os.path.normpath(os.path.join(rel_dir, f)) if rel_dir != "." else f
        if f.endswith(".swift"):
            swift_files.append((abs_path, rel))
        elif f == "PrivacyInfo.xcprivacy":
            privacy_manifest = rel

swift_files.sort(key=lambda x: x[1])

# ---------------------------------------------------------------------------
# Build object tables.
# ---------------------------------------------------------------------------

lines_build_files = []
lines_file_refs = []
sources_phase = []
resources_phase = []

# File references for swift sources, keyed by group structure.
# Group tree: nested dict {name: {"_files":[(fileref_uid, basename, rel)], subgroups...}}
tree = {}

def insert(rel, fileref_uid, basename):
    parts = rel.split(os.sep)
    node = tree
    for p in parts[:-1]:
        node = node.setdefault(p, {})
    node.setdefault("_files", []).append((fileref_uid, basename, rel))

for abs_path, rel in swift_files:
    fr = uid()
    bf = uid()
    lines_file_refs.append(
        f'\t\t{fr} /* {os.path.basename(rel)} */ = {{isa = PBXFileReference; '
        f'lastKnownFileType = sourcecode.swift; path = "{os.path.basename(rel)}"; sourceTree = "<group>"; }};'
    )
    lines_build_files.append(
        f'\t\t{bf} /* {os.path.basename(rel)} in Sources */ = {{isa = PBXBuildFile; '
        f'fileRef = {fr} /* {os.path.basename(rel)} */; }};'
    )
    sources_phase.append(f'\t\t\t\t{bf} /* {os.path.basename(rel)} in Sources */,')
    insert(rel, fr, os.path.basename(rel))

# Asset catalog (folder reference).
assets_fr = assets_bf = None
if asset_catalog:
    assets_fr = uid(); assets_bf = uid()
    lines_file_refs.append(
        f'\t\t{assets_fr} /* Assets.xcassets */ = {{isa = PBXFileReference; '
        f'lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; }};'
    )
    lines_build_files.append(
        f'\t\t{assets_bf} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; '
        f'fileRef = {assets_fr} /* Assets.xcassets */; }};'
    )
    resources_phase.append(f'\t\t\t\t{assets_bf} /* Assets.xcassets in Resources */,')

# Privacy manifest.
privacy_fr = privacy_bf = None
if privacy_manifest:
    privacy_fr = uid(); privacy_bf = uid()
    lines_file_refs.append(
        f'\t\t{privacy_fr} /* PrivacyInfo.xcprivacy */ = {{isa = PBXFileReference; '
        f'lastKnownFileType = text.plist.xml; path = PrivacyInfo.xcprivacy; sourceTree = "<group>"; }};'
    )
    lines_build_files.append(
        f'\t\t{privacy_bf} /* PrivacyInfo.xcprivacy in Resources */ = {{isa = PBXBuildFile; '
        f'fileRef = {privacy_fr} /* PrivacyInfo.xcprivacy */; }};'
    )
    resources_phase.append(f'\t\t\t\t{privacy_bf} /* PrivacyInfo.xcprivacy in Resources */,')

# Localizable.strings variant group.
variant_group_uid = None
variant_children = []
known_regions = set(["Base"])
loc_child_lines = []
if localizable_dirs:
    variant_group_uid = uid()
    variant_bf = uid()
    for lang, _path in sorted(localizable_dirs):
        known_regions.add(lang)
        child = uid()
        variant_children.append(child)
        loc_child_lines.append(
            f'\t\t{child} /* {lang} */ = {{isa = PBXFileReference; '
            f'lastKnownFileType = text.plist.strings; name = {lang}; '
            f'path = "{lang}.lproj/Localizable.strings"; sourceTree = "<group>"; }};'
        )
    lines_build_files.append(
        f'\t\t{variant_bf} /* Localizable.strings in Resources */ = {{isa = PBXBuildFile; '
        f'fileRef = {variant_group_uid} /* Localizable.strings */; }};'
    )
    resources_phase.append(f'\t\t\t\t{variant_bf} /* Localizable.strings in Resources */,')

# ---------------------------------------------------------------------------
# Emit PBXGroup tree.
# ---------------------------------------------------------------------------

group_lines = []
group_uids = {}

def emit_group(node, name, path):
    g = uid()
    children = []
    # subgroup folders first (sorted), then files
    for key in sorted(k for k in node.keys() if k != "_files"):
        sub_uid, _ = emit_group(node[key], key, key)
        children.append((sub_uid, key + "/"))
    for fr, base, rel in node.get("_files", []):
        children.append((fr, base))
    child_lines = "\n".join(f'\t\t\t\t{cu} /* {cn} */,' for cu, cn in children)
    group_lines.append(
        f'\t\t{g} /* {name} */ = {{\n'
        f'\t\t\tisa = PBXGroup;\n'
        f'\t\t\tchildren = (\n{child_lines}\n\t\t\t);\n'
        f'\t\t\tpath = "{path}";\n'
        f'\t\t\tsourceTree = "<group>";\n'
        f'\t\t}};'
    )
    return g, name

# Build the app group children: the nested tree + assets + resources group.
# We construct a synthetic root for the app folder.
app_group_uid = uid()
app_children = []

# Sub-folder groups under the app dir.
for key in sorted(k for k in tree.keys() if k != "_files"):
    sub_uid, _ = emit_group(tree[key], key, key)
    app_children.append((sub_uid, key + "/"))
# Top-level swift files (app dir root).
for fr, base, rel in tree.get("_files", []):
    app_children.append((fr, base))
# Assets.xcassets lives directly under the app dir, so it belongs in the app
# group (its path is relative to PassportQuest).
if assets_fr:
    app_children.append((assets_fr, "Assets.xcassets"))

# Privacy manifest + Localizable.strings live under PassportQuest/Resources, so
# they go in a real "Resources" group whose path makes their child paths
# (PrivacyInfo.xcprivacy, en.lproj/Localizable.strings) resolve correctly.
res_group_uid = uid()
res_children = []
if variant_group_uid:
    res_children.append((variant_group_uid, "Localizable.strings"))
if privacy_fr:
    res_children.append((privacy_fr, "PrivacyInfo.xcprivacy"))
if res_children:
    res_child_lines = "\n".join(f'\t\t\t\t{cu} /* {cn} */,' for cu, cn in res_children)
    group_lines.append(
        f'\t\t{res_group_uid} /* Resources */ = {{\n'
        f'\t\t\tisa = PBXGroup;\n'
        f'\t\t\tchildren = (\n{res_child_lines}\n\t\t\t);\n'
        f'\t\t\tpath = Resources;\n'
        f'\t\t\tsourceTree = "<group>";\n'
        f'\t\t}};'
    )
    app_children.append((res_group_uid, "Resources/"))

app_child_lines = "\n".join(f'\t\t\t\t{cu} /* {cn} */,' for cu, cn in app_children)
group_lines.append(
    f'\t\t{app_group_uid} /* {APP_DIR} */ = {{\n'
    f'\t\t\tisa = PBXGroup;\n'
    f'\t\t\tchildren = (\n{app_child_lines}\n\t\t\t);\n'
    f'\t\t\tpath = "{APP_DIR}";\n'
    f'\t\t\tsourceTree = "<group>";\n'
    f'\t\t}};'
)

# Products group.
product_ref = uid()
products_group = uid()
group_lines.append(
    f'\t\t{products_group} /* Products */ = {{\n'
    f'\t\t\tisa = PBXGroup;\n'
    f'\t\t\tchildren = (\n\t\t\t\t{product_ref} /* {PROJECT_NAME}.app */,\n\t\t\t);\n'
    f'\t\t\tname = Products;\n'
    f'\t\t\tsourceTree = "<group>";\n'
    f'\t\t}};'
)

# Main (root) group.
main_group = uid()
group_lines.append(
    f'\t\t{main_group} = {{\n'
    f'\t\t\tisa = PBXGroup;\n'
    f'\t\t\tchildren = (\n'
    f'\t\t\t\t{app_group_uid} /* {APP_DIR} */,\n'
    f'\t\t\t\t{products_group} /* Products */,\n'
    f'\t\t\t);\n'
    f'\t\t\tsourceTree = "<group>";\n'
    f'\t\t}};'
)

# Product file reference.
lines_file_refs.append(
    f'\t\t{product_ref} /* {PROJECT_NAME}.app */ = {{isa = PBXFileReference; '
    f'explicitFileType = wrapper.application; includeInIndex = 0; '
    f'path = "{PROJECT_NAME}.app"; sourceTree = BUILT_PRODUCTS_DIR; }};'
)

# ---------------------------------------------------------------------------
# Build phases, target, project, configs.
# ---------------------------------------------------------------------------

sources_phase_uid = uid()
resources_phase_uid = uid()
frameworks_phase_uid = uid()
target_uid = uid()
project_uid = uid()
target_cfg_list = uid()
project_cfg_list = uid()
debug_proj = uid(); release_proj = uid()
debug_tgt = uid(); release_tgt = uid()

known_regions_str = "\n".join(f'\t\t\t\t{r},' for r in sorted(known_regions))

# Precompute the variant group block (avoids backslashes inside f-strings).
if variant_group_uid:
    nl = chr(10)
    vc_lines = nl.join(
        f'\t\t\t\t{c} /* {l} */,'
        for c, (l, _p) in zip(variant_children, sorted(localizable_dirs))
    )
    variant_group_block = (
        f'\t\t{variant_group_uid} /* Localizable.strings */ = {{{nl}'
        f'\t\t\tisa = PBXVariantGroup;{nl}'
        f'\t\t\tchildren = ({nl}{vc_lines}{nl}\t\t\t);{nl}'
        f'\t\t\tname = Localizable.strings;{nl}'
        f'\t\t\tsourceTree = "<group>";{nl}'
        f'\t\t}};{nl}'
    )
else:
    variant_group_block = ""

common_proj_settings = """\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;
\t\t\t\tCLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tENABLE_USER_SCRIPT_SANDBOXING = YES;
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 16.0;
\t\t\t\tLOCALIZATION_PREFERS_STRING_CATALOGS = YES;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;"""

common_tgt_settings = f"""\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_ASSET_PATHS = "";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = "Passport Quest";
\t\t\t\tINFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.education";
\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UIStatusBarStyle = UIStatusBarStyleDefault;
\t\t\t\t"INFOPLIST_KEY_UISupportedInterfaceOrientations[sdk=iphoneos*]" = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\t"INFOPLIST_KEY_UISupportedInterfaceOrientations[sdk=ipados*]" = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = "@executable_path/Frameworks";
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = "{BUNDLE_ID}";
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";"""

pbxproj = f"""// !$*UTF8*$!
{{
\tarchiveVersion = 1;
\tclasses = {{
\t}};
\tobjectVersion = 56;
\tobjects = {{

/* Begin PBXBuildFile section */
{chr(10).join(lines_build_files)}
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
{chr(10).join(lines_file_refs)}
{chr(10).join(loc_child_lines)}
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
\t\t{frameworks_phase_uid} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
{chr(10).join(group_lines)}
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
\t\t{target_uid} /* {PROJECT_NAME} */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {target_cfg_list} /* Build configuration list for PBXNativeTarget "{PROJECT_NAME}" */;
\t\t\tbuildPhases = (
\t\t\t\t{sources_phase_uid} /* Sources */,
\t\t\t\t{frameworks_phase_uid} /* Frameworks */,
\t\t\t\t{resources_phase_uid} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = "{PROJECT_NAME}";
\t\t\tproductName = "{PROJECT_NAME}";
\t\t\tproductReference = {product_ref} /* {PROJECT_NAME}.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
\t\t{project_uid} /* Project object */ = {{
\t\t\tisa = PBXProject;
\t\t\tattributes = {{
\t\t\t\tBuildIndependentTargetsInParallel = 1;
\t\t\t\tLastSwiftUpdateCheck = 1500;
\t\t\t\tLastUpgradeCheck = 1500;
\t\t\t\tTargetAttributes = {{
\t\t\t\t\t{target_uid} = {{
\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;
\t\t\t\t\t}};
\t\t\t\t}};
\t\t\t}};
\t\t\tbuildConfigurationList = {project_cfg_list} /* Build configuration list for PBXProject "{PROJECT_NAME}" */;
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
{known_regions_str}
\t\t\t);
\t\t\tmainGroup = {main_group};
\t\t\tproductRefGroup = {products_group} /* Products */;
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t{target_uid} /* {PROJECT_NAME} */,
\t\t\t);
\t\t}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
\t\t{resources_phase_uid} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{chr(10).join(resources_phase)}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
\t\t{sources_phase_uid} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{chr(10).join(sources_phase)}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXSourcesBuildPhase section */

/* Begin PBXVariantGroup section */
""" + variant_group_block + f"""/* End PBXVariantGroup section */

/* Begin XCBuildConfiguration section */
\t\t{debug_proj} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
{common_proj_settings}
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tENABLE_TESTABILITY = YES;
\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;
\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (
\t\t\t\t\t"DEBUG=1",
\t\t\t\t\t"$(inherited)",
\t\t\t\t);
\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
\t\t\t\tONLY_ACTIVE_ARCH = YES;
\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{release_proj} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
{common_proj_settings}
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tENABLE_NS_ASSERTIONS = NO;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;
\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;
\t\t\t\tVALIDATE_PRODUCT = YES;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{debug_tgt} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
{common_tgt_settings}
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{release_tgt} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
{common_tgt_settings}
\t\t\t}};
\t\t\tname = Release;
\t\t}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
\t\t{project_cfg_list} /* Build configuration list for PBXProject "{PROJECT_NAME}" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{debug_proj} /* Debug */,
\t\t\t\t{release_proj} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{target_cfg_list} /* Build configuration list for PBXNativeTarget "{PROJECT_NAME}" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{debug_tgt} /* Debug */,
\t\t\t\t{release_tgt} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
/* End XCConfigurationList section */
\t}};
\trootObject = {project_uid} /* Project object */;
}}
"""

out_dir = os.path.join(ROOT, f"{PROJECT_NAME}.xcodeproj")
os.makedirs(out_dir, exist_ok=True)
with open(os.path.join(out_dir, "project.pbxproj"), "w") as f:
    f.write(pbxproj)

print(f"Wrote {out_dir}/project.pbxproj")
print(f"  swift files: {len(swift_files)}")
print(f"  asset catalog: {asset_catalog}")
print(f"  privacy manifest: {privacy_manifest}")
print(f"  localizations: {[l for l,_ in localizable_dirs]}")
