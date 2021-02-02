#Emplacement du fichier de parametre
$ini = @{}

switch -Regex -File $FichierINI
{
    "^\[(.+)\]$"{
        $section = $matches[1]
        $ini[$section] = @{}
        }
    "(.+)=(.*)"{
        $name,$value = $matches[1..2]
        $ini[$section][$name] = $value
    }
}

return $ini