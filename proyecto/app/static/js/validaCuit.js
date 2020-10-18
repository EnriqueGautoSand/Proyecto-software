function validaCuit(stringconguiones)
{    
arreglo=stringconguiones.split("-")
sCUIT=""
for (i in arreglo){
sCUIT+=arreglo[i]
}
    var aMult = '5432765432';
    var aMult = aMult.split('');
    
    if (sCUIT && sCUIT.length == 11)
    {
        aCUIT = sCUIT.split('');
        var iResult = 0;
        for(i = 0; i <= 9; i++)
        {
            iResult += aCUIT[i] * aMult[i];
        }
        iResult = (iResult % 11);
        iResult = 11 - iResult;
        
        if (iResult == 11) iResult = 0;
        if (iResult == 10) iResult = 9;
        
        if (iResult == aCUIT[10])
        {
            return true;
        }
    }    
    return false;
}