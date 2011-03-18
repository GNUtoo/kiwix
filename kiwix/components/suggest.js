/* Max sets the number of results to show in dropdown, up to 10 */
const Cc=Components;
const Ci=Cc.interfaces;
const Cg=Ci.nsIComponentRegistrar;
const g=Cc.ID("7f7984b9-acc4-4da9-a159-c378fdca4f46");
const max=5;

var lastSearchString="";

function gS(){};
gS.prototype={

    startSearch:function(searchString, searchParam, result, listener) {

	function ucFirst(str) {
	    if (str.length > 0)
		return str[0].toUpperCase() + str.substring(1);
	    else
		return str;	    
	}	

	function ulFirst(str) {
	    if (str.length > 0)
		return str[0].toLowerCase() + str.substring(1);
	    else 
		return str;
	}

	var j=this;

	/* load the zim file if necessary */
	var zimAccessor = Components.classes["@kiwix.org/zimAccessor"].getService();
	var zimAccessor = zimAccessor.QueryInterface(Components.interfaces.IZimAccessor);
	var r=[];
	
	/* Build the result array */
	zimAccessor.searchSuggestions(searchString, 50);
	var title = new Object();
	while (zimAccessor.getNextSuggestion(title))
	    r.push(title.value); 

	/* Check if equal to lastSearchString */
	if (searchString == lastSearchString)
	    return;
	else
	    lastSearchString = searchString;

	/* Check with lowercase or uppercase if we have space left in the result array */
	if (r.length < 50) {
	    if (ucFirst(searchString) == searchString)
		zimAccessor.searchSuggestions(ulFirst(searchString), 50 - r.length);
	    else 
		zimAccessor.searchSuggestions(ucFirst(searchString), 50 - r.length);	    

	    var title = new Object();
	    while (zimAccessor.getNextSuggestion(title)) {
		var present = false;
		for (i=0; i<r.length; i++) {
			if (r[0] == title.value) {
               			i = r.length +1;
				present = true;
			}
		}
		if (!present) {
        		r.push(title.value); 
			i = r.length;
		}
	    }
	}

	listener.onSearchResult(j, new gR(4,r));
    },

    stopSearch:function(){
    },
    
    QueryInterface:function(a){return this}
}

function gR(z,r){this._z=z;this._r=r;}
gR.prototype={
   _z:0,_r:[],
   get searchResult(){return this._z},
   get matchCount(){return this._r.length},
   getValueAt:function(i){return this._r[i]},
   getStyleAt:function(i){return null},
   getImageAt:function(i){return ''},
   
   QueryInterface:function(a){
       if(a.equals(Ci.nsIAutoCompleteResult))
	  return this;
   }
}
var gF={createInstance:function(o,i){return new gS().QueryInterface(i)}}
var gM={
   registerSelf:function(c,f,l,t){c.QueryInterface(Cg).registerFactoryLocation(g,"Kiwix search Suggest",
      "@mozilla.org/autocomplete/search;1?name=kiwix-suggest",f,l,t)},
   unregisterSelf:function(c,l,t){c.QueryInterface(Cg).unregisterFactoryLocation(g,l)},
   getClassObject:function(c,a,i){return gF},
   canUnload:function(c){return true}
}

function NSGetModule(c,f){return gM}