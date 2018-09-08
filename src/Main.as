/**
 * Created by mes on 08/09/2018.
 */
package
{
import appManager.displayContentElemets.TitleText;

import com.mteamapp.StringFunctions;

import contents.TextFile;

import contents.alert.Alert;

import dynamicFrame.FrameGenerator;

import flash.display.MovieClip;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.text.TextField;

public class Main extends Sprite
{
    /**It will store the last modul's comments*/
    var CommentModel:Object;
    var FullModel:Object;

    const stringFormats:Array = ["CHAR","VARCHAR","TINYTEXT","TEXT","BLOB","MEDIUMTEXT","MEDIUMBLOB","LONGTEXT","LONGBLOB","ENUM","SET",
                                    "char","varchar","text","nchar","nvarchar","ntext","binary","varbinary","image"];
    const numberFormats:Array = ["TINYINT","SMALLINT","MEDIUMINT","INT","BIGINT","FLOAT","DOUBLE","DECIMAL",
                                "bit","tinyint","smallint","int","bigint","decimal","numeric","smallmoney","money","float","real"];
    const dateFormats:Array = ["DATE","DATETIME","TIMESTAMP","TIME","YEAR",
                                "datetime","datetime2","smalldatetime","date","time","datetimeoffset","timestamp"];

    private var loadSQLMC:MovieClip,
                hintTF:TextField,
                phpModulsExportMC:MovieClip,
                logoMC:MovieClip;

    public function Main()
    {
        super();

        loadSQLMC = Obj.get("load_sql_mc",this);
        loadSQLMC.addEventListener(MouseEvent.CLICK, loadSQLFile);

        hintTF = Obj.get("hint_mc",this);
        hintTF.text = '' ;

        phpModulsExportMC = Obj.get("save_php_mc",this);
        phpModulsExportMC.visible = false ;
        phpModulsExportMC.addEventListener(MouseEvent.CLICK,generatePHPClasses);

        logoMC = Obj.get("logo_mc",this);

        FrameGenerator.createFrame(stage,-1,this);

        //var database:String = TextFile.load(File.applicationDirectory.resolvePath("database.sql"));

        //defineObjects(database);
    }

    private function loadSQLFile(e:MouseEvent):void
    {
        FileManager.browse(fileLoaded,['sql'],'Select your database SQL file to generate the moduls.');
        function fileLoaded(file:File):void
        {
            var database:String = TextFile.load(file);
            defineObjects(database);

            var count:uint = 0 ;
            for(var i:String in FullModel)
            {
                count++ ;
            }

            phpModulsExportMC.visible = true ;
            logoMC.visible = false ;

            hintTF.text = "The file is loaded and it is included "+count+" Tabel(s).";
        }
    }

    private function generatePHPClasses(e:MouseEvent):void
    {
        FileManager.browseDirectory(onDirectorySelected);
        function onDirectorySelected(directory:File):void
        {
            for(var i:String in FullModel)
            {
                var phpClasse:String = generatePHPFile(FullModel[i],i,CommentModel[i]);
                var phpFile:File = directory.resolvePath(i+'.php');
                TextFile.save(phpFile,phpClasse);
            }
            navigateToURL(new URLRequest(directory.url));
        }
    }

        /**PHP class creator*/
        private function generatePHPFile(classObject:Object,className:String,comments:Object):String
        {
            //new Alert(JSON.stringify(comments,null,' '));
            const CLASSNAME:String = "CLASSNAME";
            const PARAMETERS:String = "PARAMETERS" ;
            var PHPClassThemplet:String = "<?php\n/** Created by SaffronCode Assist */\n\nclass "+CLASSNAME+"{\n"+PARAMETERS+"\n\tpublic function __construct(){}\n}";
            PHPClassThemplet = PHPClassThemplet.replace(CLASSNAME,className);
            var params:String = "" ;
            for(var i:String in classObject)
            {
                if(comments[i] != undefined)
                    params+='\t//'+comments[i]+'\n';
                params+='\tpublic $'+i+' = '+(classObject[i] is String?'""':classObject[i])+';\n\n';
            }
            PHPClassThemplet = PHPClassThemplet.replace(PARAMETERS,params);
            return PHPClassThemplet ;
        }

    private function defineObjects(databaseSQL:String):Object
    {
        FullModel = {};
        CommentModel = {};

        var splitedFile:Array = databaseSQL.split("CREATE TABLE");
        splitedFile.shift();
        for(var i:int = 0 ; i<splitedFile.length ; i++)
        {
            //Finding model name ↓
            var currentPart:String = splitedFile[i] as String ;
            var firstParan:int = currentPart.indexOf('(');
            if(firstParan<0)
            {
                trace("This is not a tabel in the \n"+currentPart+"\n\n, skip it");
                continue;
            }
            var foundedModelName:String = currentPart.substring(0,firstParan).replace(/[\s'`]+/ig,'');
            //Alert.show("Tabel name is : "+foundedModelName);
            //Finding model name ↑

            //Findig parameters part ↓
            var paranInQue:int = 0 ;
            var lastParan:int = -1 ;
            for(var j:int = firstParan ; j<currentPart.length ; j++)
            {
                if(currentPart.charAt(j)=='(')
                    paranInQue++;
                if(currentPart.charAt(j)==')')
                    paranInQue--;
                if(paranInQue<=0)
                {
                    lastParan = j;
                    break;
                }
                trace("paranInQue : "+paranInQue);
            }

            var parametersPart:String = currentPart.substring(firstParan+1,lastParan);
            trace("parametersPart : "+parametersPart);
            //Findig parameters part ↑

            FullModel[foundedModelName] = {} ;
            CommentModel[foundedModelName] = {} ;

            //The parameters ↓

            const comaReplacment:String = "☺";
            //parametersPart = parametersPart.replace(/([^']*'[^,]*)(,)([^']*'.*)/g,'$1;$3')
            var quartMarkQue:int = 0 ;
            for(j = 0 ; j<parametersPart.length ; j++)
            {
                if(quartMarkQue==0)
                {
                    if(parametersPart.charAt(j)=="'")
                        quartMarkQue=1;
                }
                else
                {
                    if(parametersPart.charAt(j)=="'")
                        quartMarkQue=0;
                    if(parametersPart.charAt(j)==",")
                        parametersPart = parametersPart.substring(0,j)+comaReplacment+parametersPart.substring(j+1);
                }
            }
            var splitedParameters:Array = parametersPart.split(",");

            for(j = 0 ; j<splitedParameters.length ; j++)
            {
                var all:String = (splitedParameters[j] as String).split(comaReplacment).join(',') ;
                var paramName:String = all.replace(/[^`]*`(.*)`.*/,'$1').replace(/\n/g,'');
                var paramTypePart:String = all.replace(/[^`]*`.*`[\s]*(.*)/,'$1');
                var paramTypeEndIndex:int = paramTypePart.indexOf(' ');
                var absoluteType:String = paramTypePart.substr(0,paramTypeEndIndex<0?paramTypePart.length:paramTypeEndIndex).replace(/(.+)\(.*\).*/,'$1');
                if(stringFormats.indexOf(absoluteType.toLowerCase())!=-1 || stringFormats.indexOf(absoluteType.toUpperCase())!=-1)
                    FullModel[foundedModelName][paramName] = '' ;
                else if(numberFormats.indexOf(absoluteType.toLowerCase())!=-1 || numberFormats.indexOf(absoluteType.toUpperCase())!=-1)
                    FullModel[foundedModelName][paramName] = 0 ;
                else if(dateFormats.indexOf(absoluteType.toLowerCase())!=-1 || dateFormats.indexOf(absoluteType.toUpperCase())!=-1)
                    FullModel[foundedModelName][paramName] = 'Date' ;
                else
                    FullModel[foundedModelName][paramName] = '?';

                var commentPart:String = '' ;
                if(paramTypePart.indexOf(" COMMENT ")!=-1)
                {
                    commentPart = paramTypePart.replace(/.*\sCOMMENT\s'(.*)'/,'$1');
                    //new Alert("commentPart : "+commentPart);
                    CommentModel[foundedModelName][paramName] = commentPart ;
                }
            }

        }
        trace(JSON.stringify(FullModel,null,' '));
        return FullModel ;
    }
}
}
