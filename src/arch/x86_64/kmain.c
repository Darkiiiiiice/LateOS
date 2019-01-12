//
// Created by mario on 19-1-12.
//

#include "kmain.h"

int kmain() {
    char *vga = (char *)0xB8010;
    char *str = "HelloWorld\n";

    for(int i = 0;i <= LEN;i++){
        *vga++ = str[i];
        *vga++ = 0x05;
    }

    //while(*str != '\n') {
      //  *vga++ = *str++;
        //*vga++ = 0x04;
    //}
    return 0;
}