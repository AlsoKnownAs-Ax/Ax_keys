# Ax_keys

<br>
Video-Showcase: https://www.youtube.com/watch?v=LFfdl76eaGY&t=1s&ab_channel=AlsoKnownAsAx
</br>

!! For support contact --Ax-#0018 

go to vrp/client/basic_garage.lua and use this after vehicle spawn:

--> in order to turn off the vehicle (on garage spawn) use:

```lua
TriggerEvent('ax_keys:change_state',false,nveh)
```

example of parameters for the `change_state` event:

1 -> state ( false = engine OFF || true = engine ON)
2 -> nveh  ( Vehicle ID )


``````````````````````````````````````````````
AX-SHOP:           https://discord.gg/UPdRAGA7PQ

> In order to create a key use: 

```
vRPSkeys = Proxy.getInterface("vrp_keys")


vRPSkeys.Create_key({user_id,Plate_number})

```



