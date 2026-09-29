# 더존 EQT 다크 발표자료 배경 생성 (PIL+numpy) — dz-deck-builder 재현용
import numpy as np
from PIL import Image, ImageFilter
W, H = 1280, 720
def make_bg(path, cover=False):
    base = np.array([12,14,26], dtype=float)  # #0C0E1A
    img = np.tile(base,(H,W,1)); yy,xx = np.mgrid[0:H,0:W].astype(float)
    ang = np.radians(122); d = xx*np.cos(ang)+yy*np.sin(ang); d=(d-d.min())/(d.max()-d.min())
    blue=np.array([91,124,255.]); purple=np.array([167,139,250.])
    bands=[(0.80,blue,0.30),(0.87,purple,0.18),(0.74,blue,0.13),(0.92,purple,0.08)]
    if cover: bands=[(0.78,blue,0.42),(0.86,purple,0.30),(0.70,blue,0.20),(0.93,purple,0.12)]
    for c,col,amp in bands:
        w=0.045 if cover else 0.035
        img += (np.exp(-((d-c)**2)/(2*w**2))*amp)[...,None]*col
    cx,cy=(0.18*W,0.86*H); rr=np.sqrt((xx-cx)**2+(yy-cy)**2)
    img += (np.exp(-(rr**2)/(2*(0.30*W)**2))*0.10)[...,None]*blue
    Image.fromarray(np.clip(img,0,255).astype('uint8')).filter(ImageFilter.GaussianBlur(2.5)).save(path)
make_bg("bg_body.png"); make_bg("bg_cover.png", cover=True)
# 가로 그라데이션 칩
gw,gh=800,80; g=np.zeros((gh,gw,3))
b=np.array([74,108,247.]); p=np.array([167,139,250.])
for x in range(gw):
    t=x/(gw-1); g[:,x]=b*(1-t)+p*t
Image.fromarray(g.astype('uint8')).save("grad_h.png")
print("배경 3종 생성")
