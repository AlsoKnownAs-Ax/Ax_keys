--> Mergeti in invetarul vostru intrati in html/main.js ( sau cum aveti voi )
> Cautati unde se seteaza poza ( la mine era asa ):

```javascript
function setImage(item) {
    let image = item.name;
    let split = item.name.split("|");
    let split2= item.name.split("-");

    if (split[0] == "wbody") {
        image = split[1];
    }else if(split[0] == "wammo") {
        image = "ammo";
    }

    return image;
}
```

> si il transofmrati in asta : 

```javascript
    function setImage(item) {
    let image = item.name;
    let split = item.name.split("|");
    let split2= item.name.split("-");

    if (split2[0] == "key") {
        image = "key-";
        //console.log("KEY TEST")
    }else if (split[0] == "wbody") {
        image = split[1];
    }else if(split[0] == "wammo") {
        image = "ammo";
    }

    return image;
}
```

> Practic cautati cuvantul key in itemid iar daca acesta exista ii setati poza key-

> !! Functia poate sa difere de la inventar la inventar