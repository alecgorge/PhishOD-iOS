ls = """
1_nusinov_MSGnewyears_12.31.13.JPG
2001 space odyssey no wm.JPG
20yrslater no wm.JPG
2_nusinov_Merriweather_7.14.13.jpg
3_nusinov_MSGnewyears_12.31.13.jpg
4_nusinov_PortsmouthVA_6.19.13.JPG
5_nusinov_MSGnewyears_12.31.12.jpg
Gordeaux.JPG
Hampton Tweezer.JPG
TBWSIY BEST.jpg
abe wombat.JPG
best is yet to come BEST brighter.jpg
bundle of joy HIGH RES BEST.jpg
destinyunboundNOwmBRIGHTER.jpg
drowned spac without wm.jpg
firsttubenoWM.JPG
fuego AC no wm.JPG
golden age hampton no wm.jpg
gordompp.JPG
graphic translation.JPG
halfway to moon.jpg
kuroda porn hampton.JPG
light.jpg
monica AC.JPG
mpp plaid trey no wm.JPG
mpp with wm.JPG
phearlesstreynoWM.jpg
phish reading grind.JPG
photo[2] (1).JPG
rainbow hampton coliseum no wm.JPG
reading.JPG
taste the rainbow.JPG
trey jedi BEST 9.12.13 no wm.JPG
trey reading stripes.JPG
trey reading yem.JPG
trey rig more yellow no wm.jpg
truck ur face BEST.jpg
wingsuit no wm.JPG
wombat suit.JPG
"""

console.log JSON.stringify ls.trim().split("\n").map (v) -> title: "Buy a print from AZNpics on Etsy.", owner: "AZNpics/@andreanusinov", url: encodeURI("http://phishin_api.alecgorge.com/phishod_images/" + v)
