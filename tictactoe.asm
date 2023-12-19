.model small
.386
.stack 512

.data
    new_line db 13, 10, "$"

    game_draw db "                          _|_|_", 13, 10
              db "                          _|_|_", 13, 10
              db "                          _|_|_", 13, 10, "$"

    game_pointer db 9 DUP(?)

    win_flag db 0
    player db "0$"

    player_message db "                     Turno del Jugador $"
    player_win db "                     Gano el Jugador $"
    type_message db "Escribe una posicion (1-9): $"

    msg_enter_to_start db "                    Enter para comenzar$"

    authors_message db "          by Andres Parra and Mauricio Di Donato $"

    title_message db " _____                             ____                   ", 13, 10
                  db "|_   _| __ ___  ___    ___ _ __   |  _ \ __ _ _   _  __ _ ", 13, 10
                  db "| || '__/ _ \/ __|  / _ \ '_ \  | |_) / _` | | | |/ _` |", 13, 10
                  db "  | || | |  __/\__ \ |  __/ | | | |  _ < (_| | |_| | (_| |", 13, 10
                  db "  |_||_|  \___||___/  \___|_| |_| |_| \_\__,_|\__, |\__,_|", 13, 10
                  db "                                              |___/       ", 13, 10
                  db " ", 13, 10
                  db "$"


    welcome_message db "                                           ", 13, 10
                    db "                                           ", 13, 10
                    db "                              _         || ", 13, 10
                    db "                             |-|        || ", 13, 10
                    db "                         ____| |____    || ", 13, 10
                    db "                        /   _| |_   \   //", 13, 10
                    db "                       |  / ,| |. \  |_//", 13, 10
                    db "                       | ( ( '-' ) ) |-'", 13, 10
                    db "                       |  \ `'''' /  |", 13, 10
                    db "                       |   `-----'   ;", 13, 10
                    db "                       |\___________/|", 13, 10
                    db "                       |             ;", 13, 10
                    db "                        \___________/", 13, 10
                    db "                        ", 13, 10
                    db "                        ", 13, 10
                    db "$"

    user_x db " ", 13, 10
           db "Turno", 13, 10
           db "__  __", 13, 10
           db "\ \/ /", 13, 10
           db " >  < ", 13, 10
           db "/_/\_\", 13, 10
           db " ", 13, 10
           db "$"

    user_o db "  ___  ", 13, 10
           db " / _ \ ", 13, 10
           db "| (_) |", 13, 10
           db " \___/ ", 13, 10
           db "$"


.code
start proc
    mov     ax, @data
    mov     ds, ax
    mov     es, ax

    call    clear_screen

    ; Imprimir el titulo
    lea     dx, title_message
    call    print

    ; Imprime los autores
    lea     dx, authors_message
    call    print

    ; Imprimir el mensaje de bienvenida
    lea     dx, welcome_message
    call    print

    ; Mesage de dar Enter para comenzar el juego
    lea     dx, msg_enter_to_start
    call    print

    ; Leer el Enter para comenzar
    call    read_keyboard

    ; Inicia el juego
    call    set_game_pointer


main_loop:
    call    clear_screen

    lea     dx, title_message
    call    print

    lea     dx, authors_message
    call    print

    lea     dx, new_line
    call    print

    lea     dx, new_line
    call    print

    lea     dx, player_message
    call    print
    lea     dx, player
    call    print

    lea     dx, new_line
    call    print

    lea     dx, new_line
    call    print

    lea     dx, game_draw
    call    print

    lea     dx, new_line
    call    print

    lea     dx, type_message
    call    print

    ; Lee la posicion con el teclado
    call    read_keyboard

    ; calculate draw position
    sub     al, 49
    mov     bh, 0
    mov     bl, al

    call    update_draw

    call    check

    ; Revisa si el juego termino
    cmp     win_flag, 1
    je      game_over

    call    change_player

    jmp     main_loop


change_player:
    lea     si, player
    xor     ds:[si], byte ptr 1

    ret


update_draw:
    mov     bl, game_pointer[bx]
    mov     bh, 0

    lea     si, player

    cmp     ds:[si], byte ptr "0"
    je      draw_x

    cmp     ds:[si], byte ptr "1"
    je      draw_o

    draw_x:
    mov     cl, "x"
    jmp     update

    draw_o:
    mov     cl, "o"
    jmp     update

    update:
    mov     ds:[bx], cl

    ret


check:
    call    check_line
    ret


check_line:
    mov     cx, 0

    check_line_loop:
    cmp     cx, 0
    je      first_line

    cmp     cx, 1
    je      second_line

    cmp     cx, 2
    je      third_line

    call    check_column
    ret

    first_line:
    mov     si, 0
    jmp     do_check_line

    second_line:
    mov     si, 3
    jmp     do_check_line

    third_line:
    mov     si, 6
    jmp     do_check_line

    do_check_line:
    inc     cx

    mov     bh, 0
    mov     bl, game_pointer[si]
    mov     al, ds:[bx]
    cmp     al, "_"
    je      check_line_loop

    inc     si
    mov     bl, game_pointer[si]
    cmp     al, ds:[bx]
    jne     check_line_loop

    inc     si
    mov     bl, game_pointer[si]
    cmp     al, ds:[bx]
    jne     check_line_loop


    mov     win_flag, 1
    ret



check_column:
    mov     cx, 0

    check_column_loop:
    cmp     cx, 0
    je      first_column

    cmp     cx, 1
    je      second_column

    cmp     cx, 2
    je      third_column

    call    check_diagonal
    ret

    first_column:
    mov     si, 0
    jmp     do_check_column

    second_column:
    mov     si, 1
    jmp     do_check_column

    third_column:
    mov     si, 2
    jmp     do_check_column

    do_check_column:
    inc     cx

    mov     bh, 0
    mov     bl, game_pointer[si]
    mov     al, ds:[bx]
    cmp     al, "_"
    je      check_column_loop

    add     si, 3
    mov     bl, game_pointer[si]
    cmp     al, ds:[bx]
    jne     check_column_loop

    add     si, 3
    mov     bl, game_pointer[si]
    cmp     al, ds:[bx]
    jne     check_column_loop


    mov     win_flag, 1
    ret


check_diagonal:
    mov     cx, 0

    check_diagonal_loop:
    cmp     cx, 0
    je      first_diagonal

    cmp     cx, 1
    je      second_diagonal

    ret

    first_diagonal:
    mov     si, 0
    mov     dx, 4
    jmp     do_check_diagonal

    second_diagonal:
    mov     si, 2
    mov     dx, 2
    jmp     do_check_diagonal

    do_check_diagonal:
    inc     cx

    mov     bh, 0
    mov     bl, game_pointer[si]
    mov     al, ds:[bx]
    cmp     al, "_"
    je      check_diagonal_loop

    add     si, dx
    mov     bl, game_pointer[si]
    cmp     al, ds:[bx]
    jne     check_diagonal_loop

    add     si, dx
    mov     bl, game_pointer[si]
    cmp     al, ds:[bx]
    jne     check_diagonal_loop


    mov     win_flag, 1
    ret

; Cuando alguien pierde
game_over:
    call    clear_screen

    lea     dx, title_message
    call    print

    lea     dx, authors_message
    call    print

    lea     dx, new_line
    call    print

    lea     dx, new_line
    call    print

    lea     dx, new_line
    call    print

    lea     dx, game_draw
    call    print

    lea     dx, new_line
    call    print

    lea     dx, new_line
    call    print

    lea     dx, player_win
    call    print

    lea     dx, player
    call    print

    lea     dx, new_line
    call    print

    lea     dx, new_line
    call    print

    ;jmp     fim
    jmp fin


set_game_pointer:
    lea     si, game_draw+26
    lea     bx, game_pointer

    mov     cx, 9

    loop_1:
    cmp     cx, 6
    je      add_1

    cmp     cx, 3
    je      add_1

    jmp     add_2

    add_1:
    add     si, 27
    jmp     add_2


    add_2:
    mov     ds:[bx], si
    add     si, 2

    inc     bx
    loop    loop_1

    ret


; Imprime el contenido de dx
print:
    mov     ah, 9
    int     21h

    ret


; Obtiene y coloca el modo video
clear_screen:
    mov     ah, 0fh
    int     10h

    mov     ah, 0
    int     10h

    ret


read_keyboard:  ; read keybord and return content in ah
    mov     ah, 1
    int     21h

    ret


fim:
    jmp     fim

fin:
    mov ax, 4c00h
    int 21h

end start

end