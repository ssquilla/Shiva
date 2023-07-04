
using session;

namespace GUI{
    
    [GtkTemplate (ui = "/ui/Window.ui")]
    public class Window : Gtk.ApplicationWindow {

        public Window (service.Shiva app, Array<AutomatizedWebView> webViews) {
            Object(
                application: app
            );          
            setupWindowContent(webViews);
            show_all();
        }   

        public GLib.Settings settings;

        [GtkChild]
        NavigationBar navigationBar;
        [GtkChild]
        WindowContent windowContent;        

        construct{
            window_position = Gtk.WindowPosition.CENTER;
            
            loadSettings();
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
        


        public WebKit.WebView getActiveWebView(){
            return (WebKit.WebView) windowContent.get_visible_child ();
        }

        public void setupWindowContent(Array<AutomatizedWebView> webViews){
            foreach(session.AutomatizedWebView webView in webViews){
                var title = webView.networkName + " : homepage";
                var name = webView.networkName;
                windowContent.add_titled(webView,title,name);
            }
            navigationBar.setStack(windowContent);
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
