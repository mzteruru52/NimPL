# deveropped by tlllune
#
#=====-==----- -  -
#   nimplt - the plotting tool on NIM
#==========================-====-==------------- - -   -
# version Alpha 1
#
# thank you for hacking! d (・v・)
#
# project started at 2018/09/14
#
const win = defined(windows)

when win: import nltable/nlonwindows
when not win: import nltable/nlongtk
import nltable/nltypes,math,sequtils

export line

const
  ERROR_INVALID_DATA="invalid data"

var
  winSize:array[2,int]=[550,450]
  lineRange,bflineRange:array[4,float]=[0.0,0.0,0.0,0.0] # Xi,Xa,Yi,Ya

  lineSize:array[2,int]=[0,0]
  autoLineRange:array[2,bool]=[true,true]
  bvl:seq[array[2,int]]
  grps:seq[line] = @[]
  q:int
  qmx,qmy:float
  qtxt:string
  floatVal,stf:bool=true
  roundLev:int=8
  scl:int
  pls:float
  rs:seq[float]
  nmoP,bmoP:array[2,int] = [0,0]

let
  side:tuple=(80,60,40,120) # left,right,top,bottom

proc tp(n:int):float=10.0.pow(float(n))

proc roundin(n:float):float=round[float](n,roundLev)

proc txtFormat*(n:float):string=
  if floatVal:
    return $(n.roundin)
  else:
    return $(n.int)

proc toFloats*(n:seq[int] or array):seq[float]=map(n,proc(n:int):float=float(n))

proc nlLineConf*(floatValue:bool=true,roundLevel:int=8)=
  floatVal=floatValue
  roundLev=roundLevel

proc nlLine*(name:string;xdata,ydata:seq[float],color:array[3,int]):line=
  result.name=name
  result.xdata=xdata
  result.ydata=ydata
  result.color=color
  return result

proc nlSetSize*(w,h:int)=winSize=[w,h]

proc nlSetLineRange*(xmin,xmax,ymin,ymax:float=0.0)=
  if xmin!=xmax:
    autoLineRange[0]=false
    lineRange[0]=xmin
    lineRange[1]=xmax
  if ymin!=ymax:
    autoLineRange[1]=false
    lineRange[2]=ymin
    lineRange[3]=ymax

proc scales(gvi,gva:float):seq[float]=
  let grn:float=gva-gvi
  scl=0
  rs= @[gvi]
  if grn>=1.0:
    while grn>=scl.tp*10.0:scl+=1
  else:
    while grn<scl.tp:scl-=1
  pls=round[float](gvi,-scl)

  while pls<gva:
    if gvi<pls:rs.add(pls)
    pls+=scl.tp
  rs.add(gva)
  return rs

proc main

proc nlshowLine*(grp:varargs[line])=
  resetVal()
  if autoLineRange[0] or autoLineRange[1]:
    var mxi,mxa,myi,mya:seq[float]= @[]
    for G in grp:
      mxi.add(G.xdata.min)
      mxa.add(G.xdata.max)
      myi.add(G.ydata.min)
      mya.add(G.ydata.max)
    if autoLineRange[0]:(lineRange[0],lineRange[1])=(mxi.min,mxa.max)
    if autoLineRange[1]:(lineRange[2],lineRange[3])=(myi.min,mya.max)

    autoLineRange[0]=false
    autoLineRange[1]=false

  lineSize=[winSize[0]-side[1],winSize[1]-side[3]]

  proc point(n:float,fl:int):int=[
    (n-lineRange[0])/(lineRange[1]-lineRange[0])*float(winSize[0]-side[0]-side[1])+float(side[0]),
    (1-(n-lineRange[2])/(lineRange[3]-lineRange[2]))*float(winSize[1]-side[2]-side[3])+float(side[2])
    ][fl].int

  # x-border
  for i in scales(lineRange[0],lineRange[1]):
    q=point(i,0)
    qtxt=txtFormat(i)
    if i!=lineRange[0] and i!=lineRange[1]:Line(int(qtxt=="0.0" or qtxt=="0")+1,[220,220,220],@[[q,side[2]],[q,winSize[1]-side[3]]])
    if (q>side[0]+(lineSize[0] div 10) and winSize[0]-side[1]-(lineSize[0] div 10)>q) or i==lineRange[0] or i==lineRange[1]:
      text(q-5*int(floatVal)-5,winSize[1]-side[3]+20,qtxt)

  # y-border
  for i in scales(lineRange[2],lineRange[3]):
    q=point(i,1)
    qtxt=txtFormat(i)
    if i!=lineRange[2] and i!=lineRange[3]:Line(int(qtxt=="0.0" or qtxt=="0")+1,[200,200,200],@[[side[0],q],[winSize[0]-side[1],q]])
    if (q>side[2]+(lineSize[1] div 10) and winSize[1]-side[3]-(lineSize[1] div 10)>q) or i==lineRange[2] or i==lineRange[3]:
      text(20,q-12,qtxt)

  # lines
  if mto:
    Line(1,[0,0,0],@[
      [bfLineRange[0].point(0),bfLineRange[2].point(1)],
      [bfLineRange[0].point(0),bfLineRange[3].point(1)],
      [bfLineRange[1].point(0),bfLineRange[3].point(1)],
      [bfLineRange[1].point(0),bfLineRange[2].point(1)],
      [bfLineRange[0].point(0),bfLineRange[2].point(1)]
    ])
  else:
    for G in grp:
      if G.xdata.len==G.ydata.len:
        bvl = @[]
        for i in countup(0,G.xdata.len-1):
          bvl.add([point(G.xdata[i],0),point(G.ydata[i],1)])
        softLine(2,G.color,bvl)
      else:echo ERROR_INVALID_DATA

  Line(1,[100,100,100],@[
    [side[0],side[2]],
    [side[0],lineSize[1]],
    [lineSize[0],lineSize[1]],
    [lineSize[0],side[2]],
    [side[0],side[2]]
    ])
  ##echo scales(lineRange[2],lineRange[3])
  ##rect(side[0],side[2],winSize[0]-side[1],winSize[1]-side[2]-side[3],(0,0,0),0,1)

  ##softLine(5,(100,50,0),@[[10,30],[60,190],[200,140]])
  ##text(100,10,"AZaz09")
  ##rect(30,10,130,100,(50,100,200),0,0)
  if stf:
    stf=false
    for i in grp:
      grps.add(grp)
    main()
  return

proc cont(input:int)=
  if input == -1:
    nlshowLine(grps)
    redraw()
    return
  qmx = (lineRange[0]-lineRange[1])/16
  qmy = (lineRange[2]-lineRange[3])/16
  if input<5:
    if input mod 2 == 1:
      qmx *= float(input-2)
      lineRange[0]-=qmx
      lineRange[1]-=qmx
    else:
      qmy *= float(input-3)
      lineRange[2]+=qmy
      lineRange[3]+=qmy
  elif input<9:
    if input<7:
      qmx *= -1
      qmy *= -1
    lineRange[0] += qmx
    lineRange[1] -= qmx
    lineRange[2] += qmy
    lineRange[3] -= qmy
  nlshowLine(grps)
  redraw()

proc mscontsc(nmb:seq[float])=
  qmx = (lineRange[0]-lineRange[1])/float(linesize[0])*2
  qmy = (lineRange[2]-lineRange[3])/float(linesize[1])*2
  lineRange[0]+=qmx*nmb[0]
  lineRange[1]+=qmx*nmb[0]
  lineRange[2]-=qmy*nmb[1]
  lineRange[3]-=qmy*nmb[1]
  nlshowLine(grps)
  redraw()

# mainloop
proc main=
  showWin(winSize=winSize)
  while GetMessage():
    if mto:
      nmoP=mousePos()
      [nmoP[0]-bmoP[0],nmoP[1]-bmoP[1]].toFloats.mscontsc
    else:bfLineRange=lineRange
    bmoP=mousePos()
    if inp!=0:
      cont(inp)
      inp=0
    Loopin()
