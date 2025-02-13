# RPA body code 
import os,sys
import time
from time import sleep
import datetime
import pyperclip
import pyautogui
import pandas as pd
import subprocess
from subprocess import PIPE
import keyboard
from pynput import mouse
from pynput.keyboard import Key, KeyCode, Listener

import numpy as np
from PIL import Image, ImageFilter
from PIL import ImageGrab
import win32gui,win32con
import glob
from PySide6.QtCore import QPoint, Qt, QTime, QTimer
from PySide6.QtWidgets import QListWidget,QApplication,QHBoxLayout,QLineEdit, QVBoxLayout,QPushButton, QMessageBox, QWidget,QLabel,QFileDialog
import pygetwindow as gw

def CallbackButtonPressed(x,window):
    global gbn
    gbn=x
    window.close() 
    
def text_changed(x,window):
    print(window)
    global gbn
    gbn=x
    window.close() 
def text_edited(x,window):
    global comm
    comm=x
    # print("Text edited...")
    # print(comm)

def menu_pyside(pos,bn0_list,bn_list,ti):
    global window
    ppx,ppy=pyautogui.size()
    app = QApplication([])
    window = QWidget()
    window.setGeometry(int(pos[0]*ppx/100), int(pos[2]*ppy/100), int(pos[1]*ppx/100),int(pos[3]*ppy/100))
    window.setWindowTitle("COPY TOOL   copyright@T.Asao")
    window.setWindowFlag(Qt.WindowStaysOnTopHint, True)
    window.setWindowFlag(Qt.FramelessWindowHint, True)
    main_layout = QVBoxLayout()
    # QLineEdit,
    entry1=QLineEdit()
    entry1.setMaxLength(10)
    entry1.setPlaceholderText("Enter your text")
    main_layout.addWidget(entry1)
    entry1.textEdited.connect(lambda x: text_edited(x,window))
    ### サブレイアウトを作成 header bn
    sub_layout = QHBoxLayout()
    for bn in bn0_list:
        exec("{} = QPushButton('{}')".format(bn,bn))
        exec("sub_layout.addWidget({})".format(bn))
        exec("{}.pressed.connect(lambda: CallbackButtonPressed('{}',window))".format(bn,bn))
    main_layout.addLayout(sub_layout)
    #### Label
    label = QLabel()     
    label.setText(ti)
    main_layout.addWidget(label)

    # list bn 
    listwidget = QListWidget()
    listwidget.addItems(bn_list)
    listwidget.currentTextChanged.connect(lambda x: text_changed(x,window))
    main_layout.addWidget(listwidget)
    
    window.setLayout(main_layout)
    window.show()
    app.exec()
    QApplication.shutdown(app)
    return

def message(ti):# copy +
    pyperclip.copy(ti)
    app = QApplication([])
    dlg = QMessageBox()
    dlg.setWindowTitle("Copy >CB ")
    dlg.setText(ti)
    dlg.show()
    app.exec()
    QApplication.shutdown(app)
def get_file(dir,filter):
    app = QApplication([])
    caption = "Select a file"
    selectedFilter = ""
    options = QFileDialog.Options()
    fileName = QFileDialog.getOpenFileName(None,caption,dir,filter,selectedFilter,options)
    QApplication.shutdown(app)
    return fileName[0]

def hotk(h):
    h_list=["'"+i+"'" for i in h.split()]
    t=','.join(h_list)
    eval('pyautogui.hotkey({})'.format(t))
    return


def clip2pkl(path):
    tx=pyperclip.paste()
    tx=tx.replace('\r','')
    t_list=tx.split('\n')
    t_list=[i.split('\t') for i in t_list]
    dam=pd.DataFrame(t_list)
    dam.columns = dam.iloc[0]# 一行目をClumns
    dam = dam.drop(dam.index[0])
    dam.reset_index(drop=True, inplace=True)
    dam.to_pickle(path)
    return dam

def wait_ff(path_file,limit_sec):# timeout
    limit_t=time.time()
    while True:
        if  time.time()-limit_t > limit_sec:
            fl=False
            break

        elif os.path.isfile(path_file):
            make_time0=(os.path.getmtime(path_file))
            if time.time()-make_time0>1:
                continue
            else:
                fl=True
                break
        else:
            sleep(.2)
            continue
    return fl#  timeout False


# wait_file(path_file,limit_sec)# limit_sec 内に更新されるまで待つ
def watch_click_change(pos, first_click_coords):
    """
        pos=(x0,y0,x1,y1)
    1.指定した範囲のスクリーンショットを取得
    2.指定座標をクリック、スクリーンショットの変化を監視
    3.変化した場合に新たな指定座標をクリック    
    Parameters:
    - pos=(x0,y0,x1,y1)
    - region: スクリーンショットを取得する範囲 (左上X, 左上Y, 幅, 高さ)
    - first_click_coords: 初回のクリック操作の座標 (x, y)
    - second_click_coords: スクリーンショット変化時にクリックする座標 (x, y)
    """
    region=(pos[0],pos[1],pos[2]-pos[0],pos[3]-pos[1])
    # 初回のスクリーンショットを取得し、NumPy配列に変換
    initial_screenshot = pyautogui.screenshot(region=region)
    initial_screenshot_np = np.array(initial_screenshot)
    # クリック操作
    time.sleep(0.1)
    pyautogui.click(x=first_click_coords[0], y=first_click_coords[1])
    # 0.1秒間隔でスクリーンショットを取得し、初回のスクリーンショットと比較
    limit_t =time.time()
    while True:
        time.sleep(0.1)
        current_screenshot = pyautogui.screenshot(region=region)
        current_screenshot_np = np.array(current_screenshot)
        if time.time()-limit_t > 10:
            timeout_fl=1
            break
        # スクリーンショット画像の比較
        elif not np.array_equal(initial_screenshot_np, current_screenshot_np):
            print("スクリーンショットが変化しました。")
            # pyautogui.click(x=second_click_coords[0], y=second_click_coords[1])
            timeout_fl=0
            break  # ループを終了

    print("処理を終了しました。")
    return timeout_fl


def tx2list(tx,max):   # '1 2 4:6' > [1,2,4,5]
    tl=list(range(0,10000))
    tx_list=[]
    for i in tx.split():
        i_list=eval("tl[{}]".format(i))
        if isinstance(i_list, list):
            tx_list = tx_list+ i_list
        else:
            tx_list.append(i_list)
    tx_list=[i for i in tx_list if i <max+1]
    return tx_list

# def1 のKeyデータを index が一致するdfにコピー　
def index_merge(df,df1,key):
    for ind in df1.index:
        df.loc[ind,key]=df1.loc[ind,key]
    return df

def tx_extractf(t,st,ed):#  find で　入れ子になっていないことが条件 、　欠損は　['']
    res=[]
    while True:
        pos=t.find(st)
        if pos==-1:
            break
        else:
            t=t[pos+len(st):]
            posed=t.find(ed)
            if ed==-1:
                continue
            else:
                res.append(t[:posed])
                t=t[len(t[:posed])+len(ed):]
    if res ==[]:
        res=['']
    return res

def pp(*args):
    win_title=''
    if len(args)==0:# pp() : stop code
        sys.exit()
    for tx in args:
        if isinstance(tx, str):
            if tx[-3:]=='png' or tx[-3:]=='jpg':
                html_tx='<p><img src="{}" alt="Setting for RPA"></p>'.format(tx)
                path_out=os.path.join('dammy.html')
                with open(path_out, mode='w') as f:
                    f.write(html_tx)    
                win_title = open_path('dammy.html')            
            else:
                message(tx)
        elif isinstance(tx, int) or (isinstance(tx, float)):
            tx=str(tx)
            message(tx)
        elif tx is None:
            tx=' None type ' 
            message(tx)
        elif isinstance(tx, list):
            t='\n'.join(tx)
            print(t)
            message(t)
        elif (type(tx) is pd.core.frame.DataFrame):
            tx.to_html('dammy.html')
            win_title = open_path('dammy.html')
        elif (type(tx) is pd.core.series.Series):
            tx=pd.DataFrame(tx)
            tx.to_html('dammy.html')
            win_title = open_path('dammy.html')
    return win_title

def pp_t(tx):
    message(tx)

def open_path(path):
    if os.path.isdir(path):
        #hand=gethandle_exp(path)
        sub_proc=subprocess.Popen(['explorer',path],shell =True,stdout=PIPE)
    elif path[-3:]=='exe':
        sub_proc=subprocess.Popen([path],shell =True,stdout=PIPE)
    else:
        #hand=gethandle_br(path)
        sub_proc=subprocess.Popen(['start',path],shell =True,stdout=PIPE)
    sleep(2)
    hand_ex=win32gui.GetForegroundWindow()
    win_title=win32gui.GetWindowText(hand_ex)
    return win_title

# def compress(df,key):
#     def form(x):
#         x=x.dropna()
#         if len(x)==0:
#             return None
#         else:
#             return x.tolist()[-1]
#     s_list=[df.groupby(key)[col].apply(form) for col in df.columns]
#     dc=pd.concat(s_list,axis=1)
#     dc=dc.reset_index(drop=True)
#     return dc



def get_image(x1,y1,x2,y2):
    xx1=min([x1,x2])
    xx2=max([x1,x2])
    yy1=min([y1,y2])
    yy2=max([y1,y2])
    img = ImageGrab.grab()# #####  画面をキャプチャー
    #img = img.crop((xx1, yy1, xx2, yy2))
    pil_image=img
    #pil_image = img.resize((img.width *2, img.height * 2))
    arr = np.array(img)
    if os.name=='nt':
        rgb0=arr[int(yy1):int(yy2),int(xx1):int(xx2),:]#mac では二倍の精度
    else:
        rgb0=arr[2*yy1:2*yy2,2*xx1:2*xx2,:]#mac では二倍の精度
    pil_image=Image.fromarray(rgb0)
    return rgb0,pil_image,xx1,xx2,yy1,yy2

def close_win(win_title):# 開いていたら閉じる
    sleep(.5)########
    hand = win32gui.FindWindow(None,win_title) # タイトルのWindowハンドルを取得
    if hand==0:
        pass
    else:
        win32gui.PostMessage(hand,win32con.WM_CLOSE,0,0)# 閉じていてもError にならない
    return 
def fitb(xpos,width,ypos,hight):# % 最前面のWindow hanndle
    sleep(.5)
    hand = win32gui.GetForegroundWindow()
    win32gui.ShowWindow(hand, win32con.SW_SHOWNORMAL)
    win32gui.SetForegroundWindow(hand)             #ウィンドウを最前面に移動してアクティブ化
    pxx,pyy=pyautogui.size()[0],pyautogui.size()[1]
    win32gui.MoveWindow(hand,int(pxx*xpos/100), int(pyy*ypos/100), int(pxx*width/100), int(pyy*hight/100), True)#
    # win_title=win32gui.GetWindowText(hand)
    return 
def fitm(win_title):# タイトルのWinを前面に最大化
    sleep(.5)
    hand = win32gui.FindWindow(None,win_title)    #ウィンドウハンドルを取得
    win32gui.SetForegroundWindow(hand)             #ウィンドウを最前面に移動してアクティブ化
    win32gui.ShowWindow(hand ,win32con.SW_MAXIMIZE) # 最大化
    return 
def fitc(win_title,xpos,width,ypos,hight):# タイトルのWinを前面にして移動
    sleep(.5)
    hand = win32gui.FindWindow(None,win_title)    #ウィンドウハンドルを取得
    win32gui.SetForegroundWindow(hand)            #ウィンドウを最前面に移動してアクティブ化
    pxx,pyy=np.array(ImageGrab.grab()).shape[1],np.array(ImageGrab.grab()).shape[0]
    win32gui.MoveWindow(hand,int(pxx*xpos/100), int(pyy*ypos/100), int(pxx*width/100), int(pyy*hight/100), True)#
    return 

def click_xy(x,y,sl_ac):# with マウスSupression　連続Auto Click　RPA用 pyautogui 不要　
    Mouselistenersup = mouse.Listener(suppress = True)
    Mouselistenersup.start() # マウスStop 　リスナー開始
    m = mouse.Controller()
    sleep(sl_ac)
    try:
        m.position = (int(int(x)),int(int(y)))
    except:
        print('error')
        Mouselistenersup.stop() # リスナー終了
    Mouselistenersup.stop() # リスナー終了
    m.click(mouse.Button.left, 1)
    sleep(sl_ac)
    return
def move_xy(x,y,sl_ac):# with マウスSupression　連続Auto Click　RPA用 pyautogui 不要　
    Mouselistenersup = mouse.Listener(suppress = True)
    Mouselistenersup.start() # マウスStop 　リスナー開始
    m = mouse.Controller()
    sleep(sl_ac)
    try:
        m.position = (int(int(x)),int(int(y)))
    except:
        print('error')
        Mouselistenersup.stop() # リスナー終了
    Mouselistenersup.stop() # リスナー終了
    # m.click(mouse.Button.left, 1)
    sleep(sl_ac)
    return

def hotk(h):# h='ctrl a c
    h_list=["'"+i+"'" for i in h.split()]
    t=','.join(h_list)
    eval('pyautogui.hotkey({})'.format(t))
    return

def trig_ex(path_ex,x,y):
    make_time0=datetime.datetime.fromtimestamp(os.path.getmtime(path_ex))
    limit_t =time.time()
    timeout=5
    click_xy(x,y,sl_ac)# excel export Bn
    while True:
        sleep(.5)
        make_time=datetime.datetime.fromtimestamp(os.path.getmtime(path_ex))
        if make_time > make_time0:
            break
        elif time.time()-limit_t > timeout:
            timeout_fl=1
            break
    return timeout_fl

def keypress(comm,al_ac):
    comm_list=comm.split()
    for i in comm_list:
        sleep(sl_ac)
        pyautogui.hotkey(i)
    return

def input_tx(x,y,tx):# ctrl v
    click_xy(x,y,0)
    pyperclip.copy(tx)         
    hotk('ctrl v')            
    return

def input_txac(x,y,tx):# ctrl a v
    click_xy(x,y,0)
    pyperclip.copy(tx)
    hotk('ctrl a')
    sleep(1)
    hotk('ctrl v')          
    return

def paste_tx(tx):# ctrl v
    # click_xy(x,y,0)
    pyperclip.copy(tx)
    # hotkey(['ctrl','a'])
    # hotkey(['ctrl','v'])    
    hotk('ctrl v')           
    return

def paste_txac(tx):# ctrl a v
    # click_xy(x,y,0)
    pyperclip.copy(tx)
    # hotkey(['ctrl','a'])
    # hotkey(['ctrl','v']) 
    hotk('ctrl a')
    hotk('ctrl v')            
    return

# window tile にｔｘが含まれるまでtimeout_s 秒間　待機
def wait_title(tx,timeout_s):
    limit_t =time.time()
    timeout_fl=0
    while True:
        title_fgw=win32gui.GetWindowText(win32gui.GetForegroundWindow())
        if time.time()-limit_t > timeout_s:
            timeout_fl=1
            break
        elif tx in title_fgw:
            print(title_fgw)
            sleep(.5)
            break
    return timeout_fl

# window tile にｔｘが含まれるまでtimeout_s 秒間　待機 繰り返しxyＣｌｉｃｋ
def click_wait_title(tx,x,y,timeout_s):
    limit_t =time.time()
    timeout_fl=0
    click_xy(x,y,0)# click one time
    while True:
        title_fgw=win32gui.GetWindowText(win32gui.GetForegroundWindow())
        if time.time()-limit_t > timeout_s:
            timeout_fl=1
            break
        elif tx in title_fgw:
            print(title_fgw)
            sleep(.5)
            break
    sleep(sl_ac)
    return timeout_fl

def wait_imgchange(pos, first_click_coords,timeout_s):# timeout_s=10
    """
        pos=(x0,y0,x1,y1)
    1.指定した範囲のスクリーンショットを取得
    2.指定座標をクリック、スクリーンショットの変化を監視
    3.変化した場合に新たな指定座標をクリック    
    Parameters:
    - pos=(x0,y0,x1,y1)
    - region: スクリーンショットを取得する範囲 (左上X, 左上Y, 幅, 高さ)
    - first_click_coords: 初回のクリック操作の座標 (x, y)
    - second_click_coords: スクリーンショット変化時にクリックする座標 (x, y)
    """
    region=(pos[0],pos[1],pos[2]-pos[0],pos[3]-pos[1])
    # 初回のスクリーンショットを取得し、NumPy配列に変換
    initial_screenshot = pyautogui.screenshot(region=region)
    initial_screenshot_np = np.array(initial_screenshot)
    # クリック操作
    time.sleep(0.1)
    pyautogui.click(x=first_click_coords[0], y=first_click_coords[1])
    # 0.1秒間隔でスクリーンショットを取得し、初回のスクリーンショットと比較
    limit_t =time.time()
    while True:
        time.sleep(0.1)
        current_screenshot = pyautogui.screenshot(region=region)
        current_screenshot_np = np.array(current_screenshot)
        if time.time()-limit_t >timeout_s:
            timeout_fl=1
            break
        # スクリーンショット画像の比較
        elif not np.array_equal(initial_screenshot_np, current_screenshot_np):
            print("スクリーンショットが変化しました。")
            # pyautogui.click(x=second_click_coords[0], y=second_click_coords[1])
            timeout_fl=0
            break  # ループを終了
    print("処理を終了しました。")
    sleep(sl_ac)
    return timeout_fl


def cul_s(x1,y1,x2,y2):
    img = ImageGrab.grab()# #####  画面をキャプチャー
    arr = np.array(img)# pill > numpy arr
    im=arr[int(y1):int(y2),int(x1):int(x2),:]
    im_gray = 0.299 * im[:, :, 2] + 0.587 * im[:, :, 1] + 0.114 * im[:, :, 0]
    thresh=100
    im_bin = (im_gray < thresh) * 1
    s=np.sum(im_bin)
    # print(s)
    return s
def wait_imgs(x1,y1,x2,y2,s_value,timeout_s,delta):
    timeout_fl=0
    limit_t =time.time()
    while True:
        time.sleep(0.1)
        s=cul_s(x1,y1,x2,y2)
        if time.time()-limit_t >timeout_s:
            timeout_fl=1
            break
        elif (s > s_value - delta) and (s < s_value + delta):
            break
        else:
            continue
    return timeout_fl

# windows title > activation 
def win_activate(win_ti):
    fl=0
    if len(gw.getWindowsWithTitle(win_ti))!=0:
        hd = gw.getWindowsWithTitle(win_ti)[0]
        pyautogui.moveTo(int((hd.left+hd.right)/2),int((hd.top+1)))
        pyautogui.click()
        wait_title(win_ti,1)
    else:
        fl=1
    return fl
def get_pil_image(x1,y1,x2,y2):
    xx1=min([x1,x2])
    xx2=max([x1,x2])
    yy1=min([y1,y2])
    yy2=max([y1,y2])
    img = ImageGrab.grab()# #####
    arr = np.array(img)
    # print(xx1,yy1,xx2,yy2)
    if os.name=='nt':
        rgb0=arr[yy1:yy2,xx1:xx2,:]#mac では二倍の精度
    else:
        rgb0=arr[2*yy1:2*yy2,2*xx1:2*xx2,:]#mac では二倍の精度
    pil_image = Image.fromarray(rgb0)
    return pil_image,rgb0


def pos2ls():# shift でsampling して click ESC OR　10s shift なしで 終了　
    m = mouse.Controller()
    limit_t=time.time()
    limit_sec=10
    pos_list=[()]
    while True:
        if keyboard.is_pressed('shift'):
            sleep(.5)
            m.move(20,20)
            sleep(.2)
            m.move(-20,-20)
            #m.click(mouse.Button.left, 1)
            pos_list.append(m.position)
            limit_t=time.time()
            if pos_list[-1]==pos_list[-2]:# 同じ場所はカウントしない
                print('delete one same pos')
                pos_list=pos_list[:-1]
            print(pos_list)
            continue
        elif keyboard.is_pressed('esc'):# esc >end
            x1,y1,x2,y2=100,100,100,100
            break        
        elif len(pos_list) >2:#keyboard.is_pressed('esc'):# esc >end
            x1,y1,x2,y2=pos_list[1][0],pos_list[1][1],pos_list[2][0],pos_list[2][1]
            break
        elif time.time()-limit_t > limit_sec:# time out 
            print('timeout ')
            x1,y1,x2,y2=100,100,100,100
            break
        else:
            continue
    return x1,y1,x2,y2
def poslsc():# shift でsampling して click ESC OR　10s shift なしで 終了　
    m = mouse.Controller()
    limit_t=time.time()
    limit_sec=20
    pos_list=[()]
    while True:
        if keyboard.is_pressed('shift'):
            m.move(20,20)
            sleep(.2)
            m.move(-20,-20)
            sleep(.2)
            m.click(mouse.Button.left, 1)
            pos_list.append(m.position)
            limit_t=time.time()
            if pos_list[-1]==pos_list[-2]:# 同じ場所はカウントしない
                pos_list=pos_list[:-1]
            print(pos_list)
            continue
        elif keyboard.is_pressed('esc'):# esc >end
            break
        elif time.time()-limit_t > limit_sec:# time out 
            timeout_fl=1
            break
    return pos_list[1:]

def click_wait_img(pcl, pch,timeout_s,delta):# timeout_s=10 delta=6
    region=(pch[0],pch[1],delta*2,delta*2)
    # 初回のスクリーンショットを取得し、NumPy配列に変換
    initial_screenshot = pyautogui.screenshot(region=region)
    initial_screenshot_np = np.array(initial_screenshot)
    # クリック操作
    time.sleep(0.1)
    pyautogui.click(x=pcl[0], y=pcl[1])
    # 0.1秒間隔でスクリーンショットを取得し、初回のスクリーンショットと比較
    limit_t =time.time()
    while True:
        time.sleep(0.1)
        current_screenshot = pyautogui.screenshot(region=region)
        current_screenshot_np = np.array(current_screenshot)
        if time.time()-limit_t >timeout_s:
            timeout_fl=1
            break
        # スクリーンショット画像の比較
        elif not np.array_equal(initial_screenshot_np, current_screenshot_np):
            print("スクリーンショットが変化しました。")
            # pyautogui.click(x=second_click_coords[0], y=second_click_coords[1])
            timeout_fl=0
            break  # ループを終了
    print("処理を終了しました。")
    sleep(sl_ac)
    return timeout_fl

def file_list(dir ,filter):
    f_list=glob.glob(os.path.join(dir,filter))
    fname_list=[os.path.basename(i) for i in f_list]
    return f_list,fname_list

def get_pydir():
    if getattr(sys, "frozen", False):
       # The application is frozen
       datadir = os.path.dirname(sys.executable)
    else:
       # The application is not frozen
       datadir = os.path.dirname(__file__)
    return datadir

# start
path_g=get_pydir()# python directry
path_h= os.path.dirname(path_g)
sl_ac=0.2# click 間隔
timeout_fl=0
delta=6

def python_click_imgs():
    x1,y1,x2,y2=pos2ls()
    print(x1,y1,x2,y2)
    if (x1,y1,x2,y2)==(100,100,100,100):
        pass
    else:
        s_value=cul_s(x1,y1,x2,y2)
        # x1,y1=convp(x1,y1,px0,py0,px1,py1)  
        # x2,y2=convp(x2,y2,px0,py0,px1,py1)
        x,y=int((x1+x2)/2),int((y1+y2)/2)
        tx_code='## 黒の点が規定数になったらclick \n'
        tx_code+='timeout_fl=wait_imgs({},{},{},{},{},{},delta)\n'.format(x1,y1,x2,y2,s_value,5)
        tx_code+='if timeout_fl==1:\n'
        tx_code+='    pp_t("Time out  by image change "+str(cul_s({},{},{},{})))\n'.format(x1,y1,x2,y2)
        tx_code+='    sys.exit()\n'
        tx_code+='click_xy({},{},sl_ac)\n'.format(x,y)
        pyperclip.copy(tx_code)
    return tx_code
def add_cb(tx_code):
    tx=pyperclip.paste()
    tx+=tx_code+'\n'
    pyperclip.copy(tx)
    # pp(tx)
    return
def python_click():
    x,y=pos1get()
    tx_code='click_xy({},{},0)\n'.format(x,y)
    add_cb(tx_code)
    return
def pos1get():# shift でsampling して 終了　
    m = mouse.Controller()
    limit_t=time.time()
    limit_sec=20
    while True:
        if keyboard.is_pressed('shift'):
            sleep(.5)
            m.move(20,20)
            sleep(.2)
            m.move(-20,-20)
            #m.click(mouse.Button.left, 1)
            pos=m.position
            x,y=pos[0],pos[1]
            break
        elif time.time()-limit_t > limit_sec:# time out 
            # pp('timeout ')
            x,y=100,100
            break
        else:
            continue
    return x,y
def clip(tx):# tx をClipboardに入れる
    clip_tx=pyperclip.paste()
    pyperclip.copy(tx)
    return clip_tx
def read_clip():# clipbord内容を取得
    tx=pyperclip.paste()
    return tx
def paste(tx):# txをカーソル位置にペースト
    clip_tx=pyperclip.paste()
    pyperclip.copy(tx)
    hotk('ctrl v')
    return clip_tx    
def read_txt(path):
    with open(path) as f:
        tx = f.read()
    return tx
def qq(df,posq,bn0):# list 
    def qq_join(x):
        ttx=str(x.name).ljust(5)+':'
        for i in x:
            ttx+="[" +i.center(15)+ "]"
        return ttx
    
    df=df.astype(str)
    cl=[i.center(15) for i in df.columns]
    ti='INDEX#'+''.join(cl)
    if len(df)==0:
        bn_list=[]
    else:
        df['JOIN']=df.apply(qq_join,axis=1)
        bn_list=df.JOIN.tolist()
    bn0=['CANCEL']
    menu_pyside(posq,bn0,bn_list,ti)
    if gbn in bn_list:
        ind=int(gbn.split(':')[0].strip())
    else:
        ind=gbn# str for End 
    return ind
def ppp(tx):
    pp(tx)
    pp()
    return
# def1 のKeyデータを index が一致するdfにコピー　NANは上書きされない　Indexや列がｄｆになければ上書きされな
def index_merge(df,df1,key):
    df.update(df1[key])
    return df
# key が一致するda dataをdfに上書き　NAN は書き換えない　new record をdfに追加
def key_merge(df,da,key):
    def make_idf(x):
        df_pid=df[df[key] ==x]
        if len(df_pid) !=0:
            idf=df[df[key] ==x].index[0]
            return idf
        else:
            return np.nan
    df=df.reset_index(drop=True)
    len_df=len(df)
    da['IDF']= da[key].apply(make_idf)# key が一致するデータのｄｆのＩＮＤＥＸをdaに保存
    # 一致するKey dataがない　New pid
    da_nan=da[da['IDF'].isna()]
    add_ind=range(len_df,len_df+len(da_nan))
    da_nan['IDF']=add_ind
    da.update(da_nan)
    # df に追加データ用のindexを追加 
    add_df=pd.DataFrame(index=add_ind,columns=df.columns)
    df=pd.concat([df,add_df])
    # da index < IDF IDF がunique 重複をのぞく
    # da=da.duplicated(subset=key,keep='last')  
    da=da.set_index('IDF')
    # 一括書き換え
    df.update(da)
    return df
def trans2wd(x):
    if x not in dcode.index.tolist():
        return 'UNKNOWN'
    else:
        return dcode.loc[x,'WD']
# df['WD']=df.TC.apply(lambda x: dcode.loc[x,'WD'])

#@start


fitb(0,45,0,95)

path_csv='testcsv.csv'
df=pd.read_csv(path_csv,encoding="cp932")
# pp(df)
# fitb(30,70,0,95)

# ppp(df)######　　　RPAでDownloadされた前日の薬剤実施情報をCSVから取得


cl=['患者ID', '実施文書日時', '更新端末ID','患者氏名', '項目コード'
    ,'項目内容', '実施数量', '実施単位','発生日時']
df=df[cl]
df.columns='PID DT TC PNAME DCOD DG DS UT DTH'.split()
# ppp(df)######　　　　集計に必要な項目を抽出

tanmatsu_name="tanmatsucode.xlsx"
path_tanmatsu=os.path.join(path_g,tanmatsu_name)
dcode=pd.read_excel(path_tanmatsu)
dcode=dcode.set_index("実施端末ID")

# ppp(dcode)######　Excel から実施端末IDと診療科の表を取り込む


df['WD']=df.TC.apply(trans2wd)
# ppp(df)######

da=df[df.DCOD=='I4659070']
# da=df[df.DCOD=='I5750070']

# ppp(da)######　　　　　　　　　　生食シリンジの情報を抽出

da=da[da.UT=='ｍＬ']
da.UT='管'
da.DS=1

df.update(da)

# ppp(df)######

da=df[df.DCOD=='I4659070']

# ppp(da)######  　　　　　　　　　　　　　　修正後


dp=df[['DG', 'UT']]

# ppp(dp)######
wd_list='3F 4F 5F NICU 6F 7F 8F UNKNOWN'.split()
dp=df['DG UT'.split()].drop_duplicates()

# ppp(dp)#################

for cl in wd_list:
    dp[cl]=dp.DG.apply(lambda x:df[(df.DG==x) & (df.WD==cl)].DS.sum())

dp['SUM']=dp.sum(numeric_only=True,axis=1)
dp=dp.sort_values(['DG'])


ppp(dp)######　　　　　　　　病棟ごとに集計

dp.to_excel('damm.xlsx')
open_path('damm.xlsx')