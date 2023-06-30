namespace GUI{
    public class Window : Gtk.ApplicationWindow {

        public Window (service.Shiva app, Array<service.PersistentWebView> webViews) {
            Object(
                application: app
            );
            setupStack(webViews);            
            setupHeaderBar();
            show_all();
        }   

        public GLib.Settings settings;
        public GUI.HeaderBar headerBar;
        public Gtk.Stack stack { get; set; }

        construct{
            var defaut_height = 400;
            var default_width = 80;
            set_default_size (default_width,defaut_height);
            window_position = Gtk.WindowPosition.CENTER;
            //loadSettings();
            fullscreen();
            delete_event.connect(e => {
                saveSettings();
                return hide_on_delete();
            });
        }

        public void loadSettings(){
            settings = new GLib.Settings("window-position");
            move(settings.get_int("pos-x"),settings.get_int("pos-y"));
            resize(settings.get_int("window-width"),settings.get_int("window-height"));
        }
        
        public void setupStack(Array<service.PersistentWebView> webViews){
            stack = new Gtk.Stack();
            foreach(service.PersistentWebView webView in webViews){
                //stdout.printf("setup webview %s in window\n",webView.networkName);
                webView.addToStack(stack);
            }
            add(stack);
        } 

        public WebKit.WebView getActiveWebView(){
            return (WebKit.WebView) stack.get_visible_child ();
        }

        public void setupHeaderBar(){
            headerBar = new HeaderBar(this);
            set_titlebar(headerBar);
        }

        public void saveSettings(){
            int x,y, width, height;
            get_size(out width, out height);
            get_position(out x, out y);
            settings.set_int("pos-x",x);
            settings.set_int("pos-y",y);
            settings.set_int("window-width",width);
            settings.set_int("window-height",height);
        }
    }
}
