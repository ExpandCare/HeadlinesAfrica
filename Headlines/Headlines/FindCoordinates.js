//var element = document.getElementById("slsElement");
//if (element)
//{
//    return "YES";
//}
//else
//{
//    return "NO";
//}
//
//var rect = element.getBoundingClientRect();
//return rect;

function getOffset( el )
{
    var _x = 0;
    var _y = 0;
    while( el && !isNaN( el.offsetLeft ) && !isNaN( el.offsetTop))
    {
        _x += el.offsetLeft - el.scrollLeft;
        _y += el.offsetTop - el.scrollTop;
        el = el.offsetParent;
    }
    
    return { top: _y, left: _x };
}

var x = getOffset( document.getElementById('slsElement') ).left;
return "String";