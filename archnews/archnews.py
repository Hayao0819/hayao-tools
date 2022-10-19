#!/usr/bin/env python3

import wx;
import feedparser;
import sys;
import wx.html as html;

Japanese=False;


class RSSParseError(Exception):
    pass

class ArchNews():
    RSSEnglish = "http://www.archlinux.org/feeds/news/";
    RSSJapaese = "https://www.archlinux.jp/feeds/news.xml";

    def __init__(self):
        FeedURL=""
        if Japanese:
            FeedURL=self.RSSJapaese
        else:
            FeedURL=self.RSSEnglish
        self.UpdateFeed(FeedURL)


    def GetTitleList(self):
        TitleList = [];
        for entry in self.NewsList:
            TitleList.append(entry.title);
        return TitleList;

    def GetDetailFromTitle(self,Title):
        for entry in self.NewsList:
            if entry.title == Title:
                return entry.summary;
        return ""
    
    def UpdateFeed(self,url):
        self.Feed = feedparser.parse(url)
        self.NewsList=self.Feed.entries;
        
        try:
            self.Feed.status
        except (NameError, AttributeError):
            raise RSSParseError


class MainPanel(wx.Panel):
    News=None # ArchNewsオブジェクト
    CurrentHTML="" # ArchNewsから取得した現在のHTML
    
    NewsListSizer=None # 左のニュース一覧
    NewsListBox=None # 左のニュース一覧のListBox
    NewsDetailSizer=None # 右の詳細
    HTMLWindow=None # 右の詳細の中のHTMLビューアー
    WrapSizer=None # 全体

    def __init__(self, parent):
        try: 
            self.News = ArchNews();
        except RSSParseError:
            self.CreateErrorWindow();
            sys.exit(1)

        # パネル初期化
        wx.Panel.__init__(self, parent)

        self.CreateWrapSizer()
        self.CreateLeftNewsListSizer()
        self.CreateRightNewsDetailSizer()
        self.SetSizer(self.WrapSizer)

    def CreateErrorWindow(self):
        ErrorMsgBox = wx.MessageDialog(None, 'RSSの取得に失敗しました', 'RSSエラー')
        ErrorMsgBox.ShowModal()
        ErrorMsgBox.Destroy()


    def CreateWrapSizer(self):
        self.WrapSizer= wx.FlexGridSizer(rows=1, cols=2, gap=(10, 10))
        self.WrapSizer.AddGrowableCol(1) # News Detail を拡張可能にする
        self.WrapSizer.AddGrowableRow(0)
        return

    def CreateLeftNewsListSizer(self):
        self.NewsListSizer = wx.StaticBoxSizer(orient=wx.VERTICAL, parent=self, label="News List")
        self.NewsListBox = wx.ListBox(self, -1, choices=self.News.GetTitleList())
        self.NewsListSizer.Add(self.NewsListBox, 1, wx.EXPAND)
        self.Bind(wx.EVT_LISTBOX, self.NewsSelected, self.NewsListBox)
        self.WrapSizer.Add(self.NewsListSizer, 1, wx.EXPAND)
        return

    # News Detail
    def CreateRightNewsDetailSizer(self,html_text=""):
        Sizer = wx.StaticBoxSizer(orient=wx.VERTICAL, parent=self, label="News Detail")
        self.HTMLWindow = html.HtmlWindow(self,id=1); # HTMLWindowをNewsSelectedからアクセスできるようにclass全体の変数にした
        Sizer.Add(self.HTMLWindow, 1, wx.EXPAND)
        self.WrapSizer.Add(Sizer, 1, wx.EXPAND)
        return
    
    # ニュースが選択されたときに実行される関数
    def NewsSelected(self, event):
        self.UpdateNewsDetail(event.GetString())
    
    def SaveMenuHTML(self):
        print(self.CurrentHTML)

    def UpdateNewsDetail(self,title):
        self.CurrentHTML= self.News.GetDetailFromTitle(title);
        if self.CurrentHTML == "":
            self.CurrentHTML = "<h1>No News Selected</h1>";
        if self.HTMLWindow == None: #self.HTMLWindowがCreateRightNewsDetailSizerによって定義される前にこの関数が実行されると「None」が代入されているので関数を終了する
            return
        self.HTMLWindow.SetPage(self.CurrentHTML);

    def UpdateNewsListBox(self, url):
        self.News.UpdateFeed(url) # ArchNewsオブジェクトの情報を更新する
        self.NewsListBox.SetItems(self.News.GetTitleList())  # ニュースリストを更新する
        self.NewsListBox.SetSelection(0) # 先頭を選択状態にする
        self.UpdateNewsDetail(self.NewsListBox.GetString(0)) # 先頭のニュースのタイトルを取得して右のHTMLを更新する

    def SwitchLanguage(self):
        global Japanese
        if Japanese:
            self.UpdateNewsListBox(self.News.RSSEnglish)
            Japanese = False

        else:
            self.UpdateNewsListBox(self.News.RSSJapaese)
            Japanese=True;

class MainWindowFrame(wx.Frame):
    def __init__(self):
        super().__init__(None, id=-1, title='wxPython')
        self.StatusBar = self.CreateStatusBar()
        self.SetMenuBar(self.CreateMenuBar())
        self.SetStatusText("ようこそ")
        self.Panel = MainPanel(self)
        self.Show()
    
    
    def Menu_File_Save(self,event):
        self.Panel.SaveMenuHTML()
    def Menu_File_Open(self,event):
        print("未実装です", file=sys.stderr)
        return
    def Menu_File_Switch(self,event):
        self.SetStatusText("言語を切り替えています...")
        self.Panel.SwitchLanguage()
        self.SetStatusText("完了")
        return
    def Menu_File_Exit(self,event):
        sys.exit(0)

    def CreateMenuBar(self):
        MenuBar = wx.MenuBar()

        #-- ファイル --#
        # メニュー作成
        FileMenu = wx.Menu()

        # 項目作成
        FileMenuSave = FileMenu.Append(-1, "保存", "ニュースをテキストファイルに保存します\tCtrl+S")           
        self.Bind(wx.EVT_MENU, self.Menu_File_Save, FileMenuSave)

        FileMenuOpen = FileMenu.Append(-1, "開く", "RSSファイルを開きます\tCtrl+O")
        self.Bind(wx.EVT_MENU, self.Menu_File_Open, FileMenuOpen)

        FileMenuSwitch = FileMenu.Append(-1, "言語切り替え", "日本語と英語でニュースの言語を切り替えます")
        self.Bind(wx.EVT_MENU, self.Menu_File_Switch, FileMenuSwitch)

        FileMenuExit = FileMenu.Append(-1, "終了", "アプリケーションを終了します\tCtrl+Q")
        self.Bind(wx.EVT_MENU, self.Menu_File_Exit, FileMenuExit)

        # メニューバーに「ファイル」を追加
        MenuBar.Append(FileMenu, "ファイル")

        # ヘルプ
        HelpMenu = wx.Menu()
        HelpMenu.Append(-1, "使い方", "オンラインで使い方を表示します\tCtrl+U")
        HelpMenu.Append(-1, "公式サイト", "Fascode Networkの公式サイトを開きます")
        HelpMenu.Append(-1, "バージョン", 'バージョン情報を表示します\tCtrl+V')
        MenuBar.Append(HelpMenu, "ヘルプ")

        return MenuBar
    
    
if __name__ == '__main__':
    App = wx.App()
    Frame=MainWindowFrame()
    App.SetTopWindow(Frame)
    App.MainLoop()
