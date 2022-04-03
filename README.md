# Bastille-Firefly-III
Install Firefly III in a FreeBSD environment
Installation overview using XigmanasNAS Bastille Extension Gui

## Jail Setup
1. From the main screen select Extension/Bastille

2. Click ADD [+] button

3. Name (any name will work): fireflyIII

4. Configure Network Properties to your liking

5. Base Release: 12.2-Release (or newer)

6. Jail Type: 
- [ ] Create a thick container.
- [x] Enable VNET(VIMAGE).
- [ ] Create an empty container.
- [x] Start after creation.
- [x] Auto start on boot.

7. Click Create

8. Click Save

9. Restart the jail.


## Applying the Firefly template to the newly created jail

1. SSH to your Xigmanas Server

2. BOOTSTRAP the template
`bastille bootstrap https://github.com/DarkenLight/Bastille-Firefly-III`

3. Apply the Template to the TARGATE jail.
`bastille template fireflyIII DarkenLight/Bastille-Firefly-III`


## Thanks to firefly-iii Developer
https://github.com/firefly-iii/firefly-iii
