#!/usr/bin/env python3
"""
Generates PassportQuest/Data/SilhouettePaths.swift from public-domain Natural
Earth 1:110m country boundaries. Projects (equirectangular + cos-latitude),
simplifies (Douglas-Peucker), and normalises to a 0-1 unit square (north up).

Usage: python3 tools/generate_silhouettes.py
Requires network access to fetch the Natural Earth GeoJSON once.
"""
import json, math, re, os, urllib.request

URL = "https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_110m_admin_0_countries.geojson"
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB = os.path.join(ROOT, "PassportQuest/Data/CountryDatabase.swift")
OUT = os.path.join(ROOT, "PassportQuest/Data/SilhouettePaths.swift")
LARGEST_ONLY = {"US", "RU"}
MANUAL = {"XK":"kosovo","CD":"democratic republic of the congo","CG":"republic of the congo",
          "CV":"cape verde","CI":"côte d'ivoire","TL":"east timor","SZ":"eswatini",
          "GL":"greenland","AQ":"antarctica"}

def load_geo():
    with urllib.request.urlopen(URL, timeout=60) as r:
        return json.load(r)

def shoelace(r):
    return abs(sum(r[i][0]*r[i+1][1]-r[i+1][0]*r[i][1] for i in range(len(r)-1)))/2
def centroid(r):
    return (sum(p[0] for p in r)/len(r), sum(p[1] for p in r)/len(r))
def perp(pt,a,b):
    (x,y),(x1,y1),(x2,y2)=pt,a,b; dx,dy=x2-x1,y2-y1
    if dx==0 and dy==0: return math.hypot(x-x1,y-y1)
    t=max(0,min(1,((x-x1)*dx+(y-y1)*dy)/(dx*dx+dy*dy)))
    return math.hypot(x-(x1+t*dx),y-(y1+t*dy))
def dp(pts,tol):
    if len(pts)<3: return pts
    dmax,idx=0,0
    for i in range(1,len(pts)-1):
        d=perp(pts[i],pts[0],pts[-1])
        if d>dmax: dmax,idx=d,i
    if dmax>tol: return dp(pts[:idx+1],tol)[:-1]+dp(pts[idx:],tol)
    return [pts[0],pts[-1]]

def rings_of(feat):
    g=feat['geometry']
    polys=[g['coordinates'][0]] if g['type']=='Polygon' else [p[0] for p in g['coordinates']]
    return [[(c[0],c[1]) for c in r] for r in polys]

def process(cid,feat):
    rings=rings_of(feat)
    if not rings: return None
    lon=[p[0] for r in rings for p in r]
    if max(lon)-min(lon)>180:
        rings=[[((a+360 if a<0 else a),b) for a,b in r] for r in rings]
    areas=[shoelace(r) for r in rings]
    order=sorted(range(len(rings)),key=lambda i:areas[i],reverse=True)
    largest=order[0]; lc=centroid(rings[largest])
    lx=[p[0] for p in rings[largest]]; ly=[p[1] for p in rings[largest]]
    diag=math.hypot(max(lx)-min(lx),max(ly)-min(ly)); keep=[]
    for i in order:
        if cid in LARGEST_ONLY:
            if i==largest: keep.append(i)
            continue
        if areas[i]<0.12*areas[largest]: continue
        c=centroid(rings[i])
        if math.hypot(c[0]-lc[0],c[1]-lc[1])>2.2*diag: continue
        keep.append(i)
        if len(keep)>=12: break
    kept=[rings[i] for i in keep]
    pts=[p for r in kept for p in r]
    k=math.cos(math.radians(sum(p[1] for p in pts)/len(pts)))
    proj=[[(a*k,b) for a,b in r] for r in kept]
    xs=[p[0] for r in proj for p in r]; ys=[p[1] for r in proj for p in r]
    minx,miny=min(xs),min(ys); w,h=max(xs)-minx,max(ys)-miny; m=max(w,h)
    if m==0: return None
    scale=0.92/m; offx=(1-w*scale)/2; offy=(1-h*scale)/2; out=[]
    for r in proj:
        rs=dp(r,m*0.005)
        if len(rs)<4: continue
        out.append([(round(offx+(a-minx)*scale,3),round(1-(offy+(b-miny)*scale),3)) for a,b in rs])
    return out or None

def main():
    geo=load_geo()
    by_iso={}; by_name={}
    for f in geo['features']:
        p=f['properties']
        for key in ('ISO_A2_EH','ISO_A2'):
            v=p.get(key)
            if v and v!='-99' and v not in by_iso: by_iso[v]=f
        for key in ('NAME','ADMIN','NAME_LONG','NAME_EN','BRK_NAME'):
            v=p.get(key)
            if v and v.lower() not in by_name: by_name[v.lower()]=f
    db=open(DB).read(); result={}
    for e in re.split(r'Country\(id: "', db)[1:]:
        cid=e[:e.index('"')]; name=re.search(r'name: "([^"]+)"',e).group(1)
        feat=by_iso.get(cid) or by_name.get(name.lower()) or (by_name.get(MANUAL[cid]) if cid in MANUAL else None)
        if not feat: continue
        poly=process(cid,feat)
        if poly: result[cid]=poly
    emit(result)
    print("wrote", len(result), "country silhouettes")

def emit(result):
    L=['//','//  SilhouettePaths.swift','//  PassportQuest','//',
       '//  Generated from public-domain Natural Earth 1:110m boundaries by',
       '//  tools/generate_silhouettes.py. Projected, simplified and normalised',
       '//  to a 0-1 unit square (north up).','//','','import CoreGraphics','',
       'enum SilhouettePaths {','',
       '    @inline(__always) private static func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {',
       '        CGPoint(x: x, y: y)','    }','',
       '    static let polygons: [String: [[CGPoint]]] = [']
    for cid in sorted(result):
        rings=", ".join("["+", ".join(f"p({x},{y})" for x,y in r)+"]" for r in result[cid])
        L.append(f'        "{cid}": [{rings}],')
    L+=['    ]','',
        '    static func shape(for countryID: String) -> [[CGPoint]]? { polygons[countryID] }',
        '    static func points(for countryID: String) -> [[CGPoint]]? { polygons[countryID] }','',
        '    static func continentPlaceholder() -> [[CGPoint]] {',
        '        [[p(0.20, 0.30), p(0.40, 0.20), p(0.62, 0.22), p(0.80, 0.32),',
        '          p(0.84, 0.50), p(0.74, 0.68), p(0.56, 0.78), p(0.36, 0.74),',
        '          p(0.20, 0.62), p(0.14, 0.46)]]','    }','}','']
    open(OUT,'w').write("\n".join(L))

if __name__=="__main__": main()
