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

    const stringFormats:Array = ["CHAR","VARCHAR","TINYTEXT","TEXT","BLOB","MEDIUMTEXT","MEDIUMBLOB","LONGTEXT","LONGBLOB","ENUM","SET"];

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

            var splitedParameters:Array = parametersPart.split(",");

            for(j = 0 ; j<splitedParameters.length ; j++)
            {
                var paramName:String = (splitedParameters[j] as String).replace(/[^`]*`(.*)`.*/,'$1');
                var paramTypePart:String = (splitedParameters[j] as String).replace(/[^`]*`.*`[\s]*(.*)/,'$1');
                paramTypePart = paramTypePart.substring(0,paramTypePart.indexOf(' ')).replace(/(.+)\([\d]*\).*/,'$1').toUpperCase();
                if(stringFormats.indexOf(paramTypePart)!=-1)
                    FullModel[foundedModelName][paramName] = '' ;
                else
                    FullModel[foundedModelName][paramName] = paramTypePart ;

                //TODO add coments to
            }

            trace(JSON.stringify(FullModel,null,' '));
        }
    }
}
}
