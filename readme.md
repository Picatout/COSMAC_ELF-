# COSMAC elf+

![logo](docs/logo%20cosmac%20elf+avec%20fond.jpg)

J'ai fabriqué un ordinateur COSMAC elf présenté comme projet dans [Popular electronics en août 1976](https://archive.org/details/popularelectroni10unse_3/mode/2up?q=%22david+lemmel%22). Bien que le microprocesseur CDP1802 n'est plus en fabrication de nos jours, il est possible d'en trouver sur eBay. J'en avais un dans mon inventaire de composant. 

Je met la mot **elf** en minuscule car il s'agit bien d'un nom et non d'un acronyme. 

Le **elf+**  est différent de l'original au niveau de la mémoire. Alors que l'original ne disposait que de 256 octets de RAM sous la forme de 2 mémoires 2101 de 256x4 bits.  Le **elf+** possède une EEPROM de **8KO**  **AT28C64B** programmable en circuit octet par octet ainsi qu'une mémoire RAM de **32KO** **AS6C62256-55**. 

## spécifications

*  CPU **CDP1802ACE**
* mémoire EEPROM **AT28C64B** de 8KO
* mémoire **AS6C62256-55** de 32KO
* fréquence horloge **2MHZ**, testé fonctionnel avec cristal de **4MHZ**

## schématique 

![elf+ cpu](docs/elf+%20schématique-cpu.png)

![elf+ mémoire](docs/elf+%20memory.png)

![elf+ contrôle](docs/elf+%20control.png)

![elf+ carte d'extention](docs/elf+%20xboard.png)

## Assembleur utilisé 

Pour l'assemblage des programmes j'utilise [A18](https://github.com/carangil/A18). Mais il y a aussi  l'assembleur [WEB ASM80](https://beta.asm80.com/asm/1802)

## Vidéos 

J'ai créé une liste de lecture de [vidéos](https://www.youtube.com/playlist?list=PLE1bJN-R7BZ8) sur Youtube 
