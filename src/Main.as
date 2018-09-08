/**
 * Created by mes on 08/09/2018.
 */
package
{
import com.mteamapp.StringFunctions;

import contents.TextFile;

import contents.alert.Alert;

import dynamicFrame.FrameGenerator;

import flash.display.Sprite;
import flash.filesystem.File;

public class Main extends Sprite
{

    const stringFormats:Array = ["CHAR","VARCHAR","TINYTEXT","TEXT","BLOB","MEDIUMTEXT","MEDIUMBLOB","LONGTEXT","LONGBLOB","ENUM","SET",
                                    "char","varchar","text","nchar","nvarchar","ntext","binary","varbinary","image"];
    const numberFormats:Array = ["TINYINT","SMALLINT","MEDIUMINT","INT","BIGINT","FLOAT","DOUBLE","DECIMAL",
                                "bit","tinyint","smallint","int","bigint","decimal","numeric","smallmoney","money","float","real"];
    const dateFormats:Array = ["DATE","DATETIME","TIMESTAMP","TIME","YEAR",
                                "datetime","datetime2","smalldatetime","date","time","datetimeoffset","timestamp"];

    public function Main()
    {
        super();
        FrameGenerator.createFrame(stage,-1,this);

        var database:String = TextFile.load(File.applicationDirectory.resolvePath("database.sql"));

        defineObjects(database);
    }

    private function defineObjects(databaseSQL:String):void
    {
        var FullModel:Object = {} ;

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

                if(paramName.indexOf('\n')!=-1)
                    {
                        new Alert("all:"+all+" - paramName : "+paramName+" - absoluteType : "+absoluteType+" - paramTypePart : "+paramTypePart);
                    }
                //TODO add coments to
            }

            trace(JSON.stringify(FullModel,null,' '));
        }
    }
}
}
