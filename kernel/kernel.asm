; *****************************************************************
;     The DankOS kernel. It contains core drivers and routines.
; *****************************************************************

org 0x0010							; Bootloader loads us here (FFFF:0010)
bits 16								; 16-bit Real mode

; **** Bootup routines ****

; Flush registers

xor eax, eax
xor ebx, ebx
xor ecx, ecx
and edx, 0x000000FF		; (save boot drive)
xor esi, esi
xor edi, edi
xor ebp, ebp

; Setup segments

cli
mov ax, KernelSpace
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax
mov ss, ax
mov sp, 0x7FF0

push ds

xor ax, ax
mov ds, ax

mov word [0x0200], system_call		; Enable the interrupt 0x80 for the system API
mov word [0x0202], KernelSpace

mov word [0x006C], break_int		; Hook the break interrupt
mov word [0x006E], KernelSpace

mov word [0x0070], timer_int		; Hook the timer interrupt
mov word [0x0072], KernelSpace

pop ds

sti

mov byte [BootDrive], dl		; Save boot drive

push 0x29				; Set current drive
int 0x80

; Prepare the screen

push 0x80				; Enter graphics mode
int 0x80

push 0x82				; Leave graphics mode (this should fix a bug on some machines)
int 0x80

reload:

mov si, ShellName				; Use the default 'shell.bin'
mov di, ShellSwitches			; No switches
push 0x14
int 0x80						; Launch process #1

; Since process #1 is never supposed to quit, add an exception handler here

mov si, ProcessWarning1			; Print warning message (part 1)
push 0x02
int 0x80

xor cl, cl
xor dl, dl
push 0x06
int 0x80						; Print exit code

mov si, ProcessWarning2			; Print second part of message
push 0x02
int 0x80

push 0x18
int 0x80						; Pause

mov dl, byte [BootDrive]		; Set the current drive to the boot drive
push 0x29
int 0x80

jmp reload						; Reload shell


data:

ShellName		db	'shell.bin', 0x00
ProcessWarning1	db	0x0A, "Kernel: The root process has been terminated,"
				db	0x0A, "        process exit code: ", 0x00
ProcessWarning2	db	0x0A, "        The kernel will now reload 'shell.bin'."
				db	0x0A, "Press a key to continue...", 0x00
ShellSwitches	db	0x00
BootDrive		db	0x00

; ----- INTERNAL ROUTINES -----

%include 'kernel/internal/draw_cursor.inc'
%include 'kernel/internal/clear_cursor.inc'
%include 'kernel/internal/string_to_fat_name.inc'
%include 'kernel/internal/erase_dir_cache.inc'
%include 'kernel/internal/fat_delete_chain.inc'
%include 'kernel/internal/fat_get_metadata.inc'
%include 'kernel/internal/fat_load_chain.inc'
%include 'kernel/internal/fat_load_root.inc'
%include 'kernel/internal/fat_write_root.inc'
%include 'kernel/internal/fat_name_to_string.inc'
%include 'kernel/internal/fat_write_entry.inc'
%include 'kernel/internal/path_converter.inc'
%include 'kernel/internal/fat12_load_chain.inc'
%include 'kernel/internal/fat12_delete_chain.inc'
%include 'kernel/internal/floppy_read_sector.inc'
%include 'kernel/internal/floppy_write_sector.inc'
%include 'kernel/internal/check_bin_extension.inc'

; ----- EXTERNAL ROUTINES -----

%include 'kernel/external/beep.inc'
%include 'kernel/external/stop_beep.inc'
%include 'kernel/external/play_music.inc'
%include 'kernel/external/stop_music.inc'
%include 'kernel/external/compare_strings.inc'
%include 'kernel/external/input_integer.inc'
%include 'kernel/external/input_string.inc'
%include 'kernel/external/lower_to_uppercase.inc'
%include 'kernel/external/pause.inc'
%include 'kernel/external/print_integer.inc'
%include 'kernel/external/print_integer_hex.inc'
%include 'kernel/external/string_copy.inc'
%include 'kernel/external/string_end.inc'
%include 'kernel/external/string_length.inc'
%include 'kernel/external/string_to_integer.inc'
%include 'kernel/external/timer_read.inc'
%include 'kernel/external/upper_to_lowercase.inc'
%include 'kernel/external/cut_string.inc'
%include 'kernel/external/get_char.inc'
%include 'kernel/external/sleep.inc'
%include 'kernel/external/enter_graphics_mode.inc'
%include 'kernel/external/exit_graphics_mode.inc'
%include 'kernel/external/draw_pixel.inc'
%include 'kernel/external/draw_line.inc'
%include 'kernel/external/draw_sprite.inc'
%include 'kernel/external/clear_frame_buffer.inc'
%include 'kernel/external/push_frame.inc'
%include 'kernel/external/get_current_palette.inc'
%include 'kernel/external/print_string.inc'
%include 'kernel/external/center_print_string.inc'
%include 'kernel/external/initialise_screen.inc'
%include 'kernel/external/set_palette.inc'
%include 'kernel/external/disable_cursor.inc'
%include 'kernel/external/enable_cursor.inc'
%include 'kernel/external/new_line.inc'
%include 'kernel/external/get_cursor_position.inc'
%include 'kernel/external/set_cursor_position.inc'
%include 'kernel/external/put_char.inc'
%include 'kernel/external/ascii_dump.inc'
%include 'kernel/external/floppy_read_sectors.inc'
%include 'kernel/external/floppy_read_word.inc'
%include 'kernel/external/floppy_read_byte.inc'
%include 'kernel/external/floppy_read_dword.inc'
%include 'kernel/external/floppy_write_sectors.inc'
%include 'kernel/external/floppy_write_word.inc'
%include 'kernel/external/floppy_write_byte.inc'
%include 'kernel/external/floppy_write_dword.inc'
%include 'kernel/external/invalid_cache.inc'
%include 'kernel/external/set_current_drive.inc'
%include 'kernel/external/get_current_drive.inc'
%include 'kernel/external/directory_scanner.inc'
%include 'kernel/external/get_current_dir.inc'
%include 'kernel/external/load_dir.inc'
%include 'kernel/external/load_file.inc'
%include 'kernel/external/ping_file.inc'
%include 'kernel/external/fat_time_to_integer.inc'
%include 'kernel/external/get_version_number.inc'
%include 'kernel/external/terminate_process.inc'
%include 'kernel/external/start_new_program.inc'
%include 'kernel/external/allocate_memory.inc'
%include 'kernel/external/allocate_mem32.inc'

; ----- OTHER INCLUDES -----

%include 'kernel/other/timer_int.inc'
%include 'kernel/other/break_int.inc'
%include 'kernel/other/syscalls.inc'
%include 'kernel/other/variables.inc'

times 0x8000-($-$$)			db 0x00				; Pad reserved sectors with 0x00
