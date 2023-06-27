using WebKit;
using service;

namespace session{

    private enum PageState {
        CONNECT_PAGE,
        CONNECTED,
        CONNECTING,
    }


    public struct PageBlocks{
        string[] attributes;
        string[] values;
    }

    public struct DeleteElements{
        string[] attributes;
        string[] values;
    }

    class PageAutomatizer {

        public DeleteElements? deleteElements;

        public PersistentWebView persistentWebView {get; set;}

        public PageState pageState;

        public LoginManager loginManager {get; set;}

        public GUI.Window window {get; set;}

        public int splitIndex {get; set;}

        public bool firstSplit = false;

        public Array<string> splitVars;

        public PageAutomatizer (PersistentWebView webview){
            this.persistentWebView = webview;
            WebKit.Settings wks = persistentWebView.get_settings();
            wks.set_enable_write_console_messages_to_stdout (true);
            wks.set_enable_javascript (true);
            loginManager = new LoginManager(persistentWebView);
            pageState = PageState.CONNECT_PAGE;
            persistentWebView.submit_form.connect(submitForm);
            window = null;
            splitIndex = 0;
            webview.load_changed.connect(manageLoadChanged);
            this.deleteElements = webview.description.deleteElements;
            splitVars = new Array<string>();
        }

        /* ======================= HIGH LEVEL FEATURES ======================= */



        public void autoconnect(){
            if (persistentWebView.description.loginFields != null){
                assert(pageState == PageState.CONNECT_PAGE);
                fillLogins();
                clickRefuseCookiesButton();
                clickConnectButton();
            }
        }

        public bool isConnected(){
            return pageState == PageState.CONNECTED;
        }

        public void clearLogins(){
            loginManager.removeLogins();
        }

        public void setWindow(GUI.Window mainWindow){
            window = mainWindow;
        }
        
        public bool isSplitModeActivated(){
            return persistentWebView.description.pageBlocks != null && persistentWebView.description.pageBlocks.attributes.length>1;
        }

        public void shiftBlock(){
            if(isSplitModeActivated()){
                splitIndex = (splitIndex + 1) % persistentWebView.description.pageBlocks.attributes.length;
                splitBlock();
            } else {
                stdout.printf("No blocks to split for %s\n",persistentWebView.networkName);
            }
        }

        public void splitBlock(){
            assert(isSplitModeActivated());
            if(true){//!firstSplit){
                executeDeleteElements();
                stdout.printf("Loading split vars ...\n");
                loadBlocksVars();
                firstSplit = true;
            }
            stdout.printf("Setting split screen ...\n");
            string focusScript = builtScriptFocusBlock();
            ssize_t length = (ssize_t) focusScript.length;
            stdout.printf(focusScript);
            persistentWebView.evaluate_javascript(focusScript,length,null,null,null);
            //stdout.printf(focusScript);
        }

        /* ======================= LOW LEVEL FEATURES ======================== */

        public void executeScript(string script){
            ssize_t length = (ssize_t) script.length;
            persistentWebView.evaluate_javascript(script,length,null,null,null);
        }

        public void manageLoadChanged(WebKit.LoadEvent load_event){
            if (load_event == WebKit.LoadEvent.FINISHED && pageState == PageState.CONNECT_PAGE){
                autoconnect();
                pageState = PageState.CONNECTING;
            } else if (load_event == WebKit.LoadEvent.FINISHED && pageState == PageState.CONNECTING){
                //shiftBlock();
                pageState = PageState.CONNECTED;
            } else {

            }
        }


        /* --------------- shifting blocks -------------------------- */

        // créer le script qui cherche le 1er node qui respecte attribute == value
        // la variable est stoquée dans la variable varName
        // si les champs sont pertinents, btn ne sera pas null. Sinon, il reste à null.
        public string builtScriptSearchNode(string attribute, string value, string varName){
            string script = "var nodes = document.querySelectorAll('["+attribute+"=\""+value+"\"]');\n";
            script += "var " + varName + "= nodes[0];\n";
            script += "console.log(" + varName + " + nodes.length + ' elements founds ');\n";
            //script += "console.log(nodes[0].getAttribute(\"data-testid\"));\n";
            return script;
        }

        public string formatVarName(string varName){
            return varName.replace(" ","_").replace("'","_").replace("-","_");
        }

        public void loadBlocksVars(){
            splitVars = new Array<string>();
            var blocksAttributes = persistentWebView.description.pageBlocks.attributes;
            var blocksValues = persistentWebView.description.pageBlocks.values;
            string script = "";
            for (int i=0;i<blocksAttributes.length;i++){
                var varName = persistentWebView.description.networkName + "_" + blocksAttributes[i] + "_" + blocksValues[i];
                varName = formatVarName(varName);
                splitVars.append_val(varName);
                assert(!varName.contains(" "));
                script += builtScriptSearchNode(blocksAttributes[i],blocksValues[i],varName);
            }
            executeScript(script);
        }

        public string builtScriptFocusBlock(){
            var blocksAttributes = persistentWebView.description.pageBlocks.attributes;
            var blocksValues = persistentWebView.description.pageBlocks.values;
            string script = "";
            for (int i=0;i<splitVars.length;i++){
                var varName = splitVars.index(i);
                assert(!varName.contains(" "));
                assert(!varName.contains("-"));
                if(i==splitIndex){
                    script += varName+".style = \"display: flex;flex-basis:100%;max-width:100%\";\n";
                } else {
                    script += varName+".style.display='none';\n";
                }
                //script += "console.log(" + varName + " + 'elements founds ');\n";
            }
            return script;
        }

        /* ---------------------- connecting & logins ---------------------- */
        public void submitForm (FormSubmissionRequest request){
            if(pageState == PageState.CONNECT_PAGE){
                stdout.printf("submit form...\n");
                if (loginManager!=null){
                    //print("%s\n","heho");
                    GenericArray<string> field_names = new GenericArray<string>();
                    GenericArray<string> field_values = new GenericArray<string>();
                    
                    bool notEmpty = request.list_text_fields(out field_names,out field_values);
                    if (notEmpty) {
                        string? loginValue = null;
                        string? passValue = null;
                        for(int i=0;i<field_names.length;i++){
                            if(field_names[i]==persistentWebView.loginFields.loginField){
                                loginValue = field_values[i];
                            } else if(field_names[i]==persistentWebView.loginFields.passField){
                                passValue = field_values[i];
                            }
                            //stdout.printf ("%s",field_names[i]+": "+field_values[i]+"\n");
                        }
                        if(loginValue!=null && passValue!=null){
                            var dialog = new session.UpdateLoginsDialog(loginValue,passValue,window,loginManager);
                        }
                    }
                }
                request.submit();
            }
        }

        /*
        public string printJs() {
            string script = "console.log('Bonjour !');";
            return script;
        }

        public void callJavascript(){
            var script = printJs();
            ssize_t length = (ssize_t) script.length;
            persistentWebView.evaluate_javascript(script,length,null,null,null);
        }
        */

        public string? buildConnectJs() {
            string loginValue;
            string passValue;
            session.ConnectingValues? logins = loginManager.lookupLogins();
            if (logins != null){
                loginValue = logins.login;
                passValue = logins.password;
                var loginField = persistentWebView.loginFields.loginField;
                var passField = persistentWebView.loginFields.passField;
                //stdout.printf("%s,%s,%s,%s",loginField,loginValue,passField,passValue);
                //string script = "console.log('Filling fields ... !');";
                string script = "";
                script += builtScriptFillValue(loginField,loginValue);
                //stdout.printf(script);
                script += builtScriptFillValue(passField,passValue);
                return script;
            } else {
                return null;
            }

        }


        public string builtScriptFillValue(string fieldID, string fieldValue){
            //return "console.log(document.getElementById('" + fieldID + "'));" + "console.log('"+ fieldID + "');";
            return "document.getElementById('" + fieldID + "').value = '" + fieldValue +"';\n";
        }

        public void fillLogins(){
            if (persistentWebView.needLogins()){
                var script = buildConnectJs();
                if (script != null){
                    stdout.printf("Recovering logins ...\n");
                    ssize_t length = (ssize_t) script.length;
                    persistentWebView.evaluate_javascript(script,length,null,null,null);
                } else {
                    stdout.printf("No logins found.\n");
                }
            }
        }

        public void executeDeleteElements(){
            if(persistentWebView.description.deleteElements != null){
                stdout.printf("Deleting some elements ...\n");
                string[] deleteAttributes = persistentWebView.description.deleteElements.attributes;
                string[] deleteValues = persistentWebView.description.deleteElements.values;
                
                for(int i=0;i<deleteAttributes.length;i++){
                    string script = "";
                    string[] clues = {deleteValues[i]};
                    string[] fields = {deleteAttributes[i]};
                    string varName = "delete_" + deleteAttributes[i] +"_" + deleteValues[i];
                    varName = formatVarName(varName);
                    script += builtScriptSearchElement(clues, fields, varName, "*");
                    script += varName+".remove();\n";
                    stdout.printf(script);
                    ssize_t length = (ssize_t) script.length;
                    persistentWebView.evaluate_javascript(script,length,null,null,null);
                }
            }
        }

        // créer le script qui cherche le bouton qui contient le plus d'éléments de "indices" dans ses champs de "fields"
        // la variable est stoquée dans la variable btn
        // si les champs sont pertinents, btn ne sera pas null. Sinon, il reste à null.
        public string builtScriptSearchElement(string[] clues, string[] fields, string varName, string elementType){
            string script = "var btns = document.querySelectorAll('"+elementType+"');\n";
            //script += "console.log( btns.length + ' candidates divs');\n";
            script += "function countClues(node){ return (";
            // empiler les indices pour trouver le bouton
            for(int i=0;i<clues.length;i++){
                var indice = clues[i];
                for(int j=0;j<clues.length;j++){
                    var field = fields[j];
                    script += "(node.hasAttribute('"+field+"') && (node.getAttribute('"+field+"') =='" + indice +"')) ";
                    if (i<clues.length-1 || j<clues.length-1){
                        script += "+";
                    }
                }

            }
            script += "); }\n";// * (node.type=='"+elementType+"'); }\n";
            // chercher le boutton avec l'indice le plus haut
            script += "var " + varName + " = null; maxMeasure = 0;\n";
            script += "for (let i = 0; i < btns.length; i++) {";
            script += "   if(countClues(btns[i])>maxMeasure){";
            script += "     " + varName + " = btns[i] ; maxMeasure = countClues(btns[i]);  }\n";
            script += "}\n";
            //script += "console.log(" + varName + "+ ' found');\n";
            //stdout.printf(script);
            return script;
        }        

        // créer le script qui cherche le bouton qui contient le plus d'éléments de "indices" dans ses champs de "fields"
        // la variable est stoquée dans la variable btn
        // si les champs sont pertinents, btn ne sera pas null. Sinon, il reste à null.
        public string builtScriptSearchSubmitButton(string[] clues, string[] fields, string buttonName){
            string script = "var btns = document.querySelectorAll('button');\n";
            script += "console.log( btns.length + ' candidates buttons');\n";
            script += "function countClues(node){ return (";
            // empiler les indices pour trouver le bouton
            for(int i=0;i<clues.length;i++){
                var indice = clues[i];
                for(int j=0;j<clues.length;j++){
                    var field = fields[j];
                    script += "((node.getAttribute('"+field+"') != null) && (node.getAttribute('"+field+"').contains('" + indice +"'))) ";
                    if (i<clues.length-1 || j<clues.length-1){
                        script += "+";
                    }
                }

            }
            script += ") * (node.type=='submit'); }\n";
            // chercher le boutton avec l'indice le plus haut
            script += "var " + buttonName + " = null; maxMeasure = 0;\n";
            script += "for (let i = 0; i < btns.length; i++) {";
            script += "   if(countClues(btns[i])>maxMeasure){";
            script += "     " + buttonName + " = btns[i] ; maxMeasure = countClues(btns[i]);  }\n";
            script += "}\n";
            script += "console.log(" + buttonName + "+ ' found');\n";
            //stdout.printf(script);
            return script;
        }

        public string addClickToScript(string script, string buttonName){
            var script_click = script + (buttonName + ".click();\n");
            return script_click;
        }

        public void clickConnectButton(){
            var buttonName = "connectButton";
            string[] clues = {"login","connect"};
            string[] fields = {"id","name"};
            /*
			<button value="1" class="_42ft _4jy0 _3_t3 _2qcm _9g9c _4jy4 _517h _51sy" id="loginbutton" name="login" tabindex="0" type="submit">Se connecter</button>
			*/
            var script = builtScriptSearchSubmitButton(clues, fields, buttonName);
            script = addClickToScript(script,buttonName);
            ssize_t length = (ssize_t) script.length;
            persistentWebView.evaluate_javascript(script,length,null,null,null);
            stdout.printf("Trying to locate and click on 'login' button\n");
        }

        public void clickRefuseCookiesButton(){
            var buttonName = "refuseCookiesButton";
            string[] clues = {"accept_only_essential","Refuse"};
            string[] fields = {"data-cookiebanner","data-testid","title"};

            /* refuser
            <button value="1" class="_42ft _4jy0 _alf7 _4jy3 _4jy1 selected _51sy" 
            data-cookiebanner="accept_only_essential_button" 
            data-testid="cookie-policy-manage-dialog-accept-button"
            title="Refuser les cookies optionnels" type="submit" 
            id="u_0_g_pb">Refuser les cookies optionnels</button>*/

            /* autoriser
            <button value="1" class="_42ft _4jy0 _alf6 _4jy3 _4jy1 selected _51sy"
             data-cookiebanner="accept_button"
             data-testid="cookie-policy-manage-dialog-accept-button"
             title="Autoriser tous les cookies" type="submit" 
             id="u_0_h_hk">Autoriser tous les cookies</button> */

            var script = builtScriptSearchSubmitButton(clues, fields, buttonName);
            script = addClickToScript(script,buttonName);
            ssize_t length = (ssize_t) script.length;
            persistentWebView.evaluate_javascript(script,length,null,null,null);
            stdout.printf("Trying to locate and click on 'refuse cookies' button\n");
        }

    }
}