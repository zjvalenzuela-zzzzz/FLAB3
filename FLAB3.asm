; ZACK GABRIEL J. VALENZUELA
; SOLAR / COR ENROLLMENT AND TUITION CALCULATOR
; NASM 32-bit Assembly for Linux

BITS 32
GLOBAL _start

%macro PRINT 2
    mov eax, 4
    mov ebx, 1
    mov ecx, %1
    mov edx, %2
    int 0x80
%endmacro

%macro ASK_STRING 4
    PRINT %1, %2
    push dword %4
    push dword %3
    call read_line
    add esp, 8
%endmacro

%macro ASK_INTEGER 3
    PRINT %1, %2
    call read_integer
    mov [%3], eax
%endmacro

SECTION .data

    heading db 10, '============================================', 10
            db '       SOLAR / COR TUITION CALCULATOR', 10
            db '============================================', 10, 10
    heading_len equ $ - heading

    student_heading db 10, '--- ENTER STUDENT INFORMATION ---', 10
    student_heading_len equ $ - student_heading

    p_status db 'Enrollment Status (e.g., ENROLLED):', 10
    p_status_len equ $ - p_status

    p_student_no db 'Student Number:', 10
    p_student_no_len equ $ - p_student_no

    p_name db 'Full Name:', 10
    p_name_len equ $ - p_name

    p_phone db 'Phone Number:', 10
    p_phone_len equ $ - p_phone

    p_zip db 'ZIP Code:', 10
    p_zip_len equ $ - p_zip

    p_college db 'College:', 10
    p_college_len equ $ - p_college

    p_program db 'Program:', 10
    p_program_len equ $ - p_program

    p_year_level db 'Year Level:', 10
    p_year_level_len equ $ - p_year_level

    p_term db 'Term (e.g., 1st term):', 10
    p_term_len equ $ - p_term

    p_school_year db 'School Year (e.g., SY 2026-2027):', 10
    p_school_year_len equ $ - p_school_year

    p_address db 'Complete Address:', 10
    p_address_len equ $ - p_address

    summary_heading db 10, '--- STUDENT INFORMATION SUMMARY ---', 10
    summary_heading_len equ $ - summary_heading

    l_status db 'Enrollment Status: '
    l_status_len equ $ - l_status

    l_student_no db 'Student Number: '
    l_student_no_len equ $ - l_student_no

    l_name db 'Name: '
    l_name_len equ $ - l_name

    l_phone db 'Phone: '
    l_phone_len equ $ - l_phone

    l_zip db 'ZIP Code: '
    l_zip_len equ $ - l_zip

    l_college db 'College: '
    l_college_len equ $ - l_college

    l_program db 'Program: '
    l_program_len equ $ - l_program

    l_year_level db 'Year Level: '
    l_year_level_len equ $ - l_year_level

    l_term db 'Term: '
    l_term_len equ $ - l_term

    l_school_year db 'School Year: '
    l_school_year_len equ $ - l_school_year

    l_address db 'Address: '
    l_address_len equ $ - l_address

    subjects_heading db 10, '--- SUBJECTS AND UNITS ---', 10
                     db 'Enter 0 units if you are not taking a subject.', 10
    subjects_heading_len equ $ - subjects_heading

    units_prompt db '   Units for this subject (whole number): ', 10
    units_prompt_len equ $ - units_prompt

    unit_summary_heading db 10, '--- SUBJECT UNIT SUMMARY ---', 10
    unit_summary_heading_len equ $ - unit_summary_heading

    units_label db '  Units: '
    units_label_len equ $ - units_label

    fee_heading db 10, '--- TUITION FEE SUMMARY ---', 10
    fee_heading_len equ $ - fee_heading

    label_total_units db 'Total units: '
    label_total_units_len equ $ - label_total_units

    label_unit_price db 'Unit price: PHP '
    label_unit_price_len equ $ - label_unit_price

    label_tuition db 'Tuition (total units x PHP 1,000): PHP '
    label_tuition_len equ $ - label_tuition

    label_lab_subjects db 'Laboratory subjects taken: '
    label_lab_subjects_len equ $ - label_lab_subjects

    label_lab_fee db 'Laboratory fee (PHP 2,500 each): PHP '
    label_lab_fee_len equ $ - label_lab_fee

    label_total_due db 'TOTAL ESTIMATED TUITION + LAB FEES: PHP '
    label_total_due_len equ $ - label_total_due

    footer db 10, 'Note: This estimate excludes miscellaneous, ID validation,', 10
           db 'and any other fees not specified in the calculation.', 10
    footer_len equ $ - footer

    newline db 10
    newline_len equ $ - newline

    zero_text db '0', 0

    subj1  db '1. CCS0021  - INFORMATION MANAGEMENT (LEC)', 0
    subj2  db '2. CCS0021L - INFORMATION MANAGEMENT (LAB)', 0
    subj3  db '3. CS0001   - DISCRETE STRUCTURES I', 0
    subj4  db '4. CS0003   - COMPUTER SYSTEMS & ARCHITECTURE', 0
    subj5  db '5. CS0003L  - COMPUTER SYSTEMS & ARCHITECTURE (LAB)', 0
    subj6  db '6. CS0070   - OBJECT ORIENTED PROGRAMMING', 0
    subj7  db '7. CS0070L  - OBJECT ORIENTED PROGRAMMING-LAB', 0
    subj8  db '8. GED0021  - SPECIALIZED ENGLISH PROGRAM 2', 0
    subj9  db '9. GED0055  - MATHEMATICAL ANALYSIS', 0
    subj10 db '10. GED0081  - COLLEGE PHYSICS 1 LECTURE', 0
    subj11 db '11. GED0081L - COLLEGE PHYSICS 1 LABORATORY', 0

    subject_table dd subj1, subj2, subj3, subj4, subj5, subj6
                  dd subj7, subj8, subj9, subj10, subj11

    lab_flags db 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1

    php_unit_price equ 1000
    php_lab_price equ 2500

SECTION .bss

    status_buf       resb 128
    student_no_buf   resb 128
    name_buf         resb 128
    phone_buf        resb 128
    zip_buf          resb 128
    college_buf      resb 128
    program_buf      resb 128
    year_level_buf   resb 128
    term_buf         resb 128
    school_year_buf  resb 128
    address_buf      resb 128

    integer_buffer resb 32

    units_array resd 11

    total_units resd 1
    lab_subject_count resd 1
    tuition_amount resd 1
    lab_amount resd 1
    total_amount resd 1

    digit_buffer resb 16

SECTION .text

_start:

    PRINT heading, heading_len
    PRINT student_heading, student_heading_len

    ASK_STRING p_status, p_status_len, status_buf, 128
    ASK_STRING p_student_no, p_student_no_len, student_no_buf, 128
    ASK_STRING p_name, p_name_len, name_buf, 128
    ASK_STRING p_phone, p_phone_len, phone_buf, 128
    ASK_STRING p_zip, p_zip_len, zip_buf, 128
    ASK_STRING p_college, p_college_len, college_buf, 128
    ASK_STRING p_program, p_program_len, program_buf, 128
    ASK_STRING p_year_level, p_year_level_len, year_level_buf, 128
    ASK_STRING p_term, p_term_len, term_buf, 128
    ASK_STRING p_school_year, p_school_year_len, school_year_buf, 128
    ASK_STRING p_address, p_address_len, address_buf, 128

    PRINT summary_heading, summary_heading_len

    PRINT l_status, l_status_len
    push dword status_buf
    call print_string
    add esp, 4
    PRINT newline, newline_len

    PRINT l_student_no, l_student_no_len
    push dword student_no_buf
    call print_string
    add esp, 4
    PRINT newline, newline_len

    PRINT l_name, l_name_len
    push dword name_buf
    call print_string
    add esp, 4
    PRINT newline, newline_len

    PRINT l_phone, l_phone_len
    push dword phone_buf
    call print_string
    add esp, 4
    PRINT newline, newline_len

    PRINT l_zip, l_zip_len
    push dword zip_buf
    call print_string
    add esp, 4
    PRINT newline, newline_len

    PRINT l_college, l_college_len
    push dword college_buf
    call print_string
    add esp, 4
    PRINT newline, newline_len

    PRINT l_program, l_program_len
    push dword program_buf
    call print_string
    add esp, 4
    PRINT newline, newline_len

    PRINT l_year_level, l_year_level_len
    push dword year_level_buf
    call print_string
    add esp, 4
    PRINT newline, newline_len

    PRINT l_term, l_term_len
    push dword term_buf
    call print_string
    add esp, 4
    PRINT newline, newline_len

    PRINT l_school_year, l_school_year_len
    push dword school_year_buf
    call print_string
    add esp, 4
    PRINT newline, newline_len

    PRINT l_address, l_address_len
    push dword address_buf
    call print_string
    add esp, 4
    PRINT newline, newline_len

    mov dword [total_units], 0
    mov dword [lab_subject_count], 0

    PRINT subjects_heading, subjects_heading_len

    xor esi, esi

.collect_subjects:

    cmp esi, 11
    jge .subjects_done

    mov eax, [subject_table + esi*4]
    push eax
    call print_string
    add esp, 4

    PRINT newline, newline_len
    PRINT units_prompt, units_prompt_len

    call read_integer

    mov [units_array + esi*4], eax
    add [total_units], eax

    cmp eax, 0
    jle .next_subject

    cmp byte [lab_flags + esi], 1
    jne .next_subject

    inc dword [lab_subject_count]

.next_subject:

    inc esi
    jmp .collect_subjects

.subjects_done:

    mov eax, [total_units]
    imul eax, php_unit_price
    mov [tuition_amount], eax

    mov eax, [lab_subject_count]
    imul eax, php_lab_price
    mov [lab_amount], eax

    mov eax, [tuition_amount]
    add eax, [lab_amount]
    mov [total_amount], eax

    PRINT unit_summary_heading, unit_summary_heading_len

    xor esi, esi

.show_subjects:

    cmp esi, 11
    jge .show_fees

    mov eax, [subject_table + esi*4]
    push eax
    call print_string
    add esp, 4

    PRINT units_label, units_label_len

    push dword [units_array + esi*4]
    call print_uint
    add esp, 4

    PRINT newline, newline_len

    inc esi
    jmp .show_subjects

.show_fees:

    PRINT fee_heading, fee_heading_len

    PRINT label_total_units, label_total_units_len
    push dword [total_units]
    call print_uint
    add esp, 4
    PRINT newline, newline_len

    PRINT label_unit_price, label_unit_price_len
    push dword php_unit_price
    call print_uint
    add esp, 4
    PRINT newline, newline_len

    PRINT label_tuition, label_tuition_len
    push dword [tuition_amount]
    call print_uint
    add esp, 4
    PRINT newline, newline_len

    PRINT label_lab_subjects, label_lab_subjects_len
    push dword [lab_subject_count]
    call print_uint
    add esp, 4
    PRINT newline, newline_len

    PRINT label_lab_fee, label_lab_fee_len
    push dword [lab_amount]
    call print_uint
    add esp, 4
    PRINT newline, newline_len

    PRINT label_total_due, label_total_due_len
    push dword [total_amount]
    call print_uint
    add esp, 4
    PRINT newline, newline_len

    PRINT footer, footer_len

    mov eax, 1
    xor ebx, ebx
    int 0x80

print_string:

    push ebp
    mov ebp, esp

    push ebx
    push esi

    mov esi, [ebp+8]
    xor edx, edx

.count_chars:

    cmp byte [esi+edx], 0
    je .write_chars

    inc edx
    jmp .count_chars

.write_chars:

    test edx, edx
    jz .print_done

    mov eax, 4
    mov ebx, 1
    mov ecx, esi
    int 0x80

.print_done:

    pop esi
    pop ebx

    mov esp, ebp
    pop ebp
    ret

read_line:

    push ebp
    mov ebp, esp

    push ebx
    push esi
    push edi

    mov esi, [ebp+8]
    mov edx, [ebp+12]
    dec edx

    mov eax, 3
    xor ebx, ebx
    mov ecx, esi
    int 0x80

    test eax, eax
    jle .empty_line

    mov edi, eax
    mov byte [esi+edi], 0

    cmp byte [esi+edi-1], 10
    jne .check_cr

    mov byte [esi+edi-1], 0
    dec edi

.check_cr:

    cmp edi, 0
    je .line_done

    cmp byte [esi+edi-1], 13
    jne .line_done

    mov byte [esi+edi-1], 0
    jmp .line_done

.empty_line:

    mov byte [esi], 0

.line_done:

    pop edi
    pop esi
    pop ebx

    mov esp, ebp
    pop ebp
    ret

read_integer:

    push ebp
    mov ebp, esp

    push ebx
    push esi
    push edx

    push dword 32
    push dword integer_buffer
    call read_line
    add esp, 8

    mov esi, integer_buffer
    xor eax, eax

.parse_digit:

    mov bl, [esi]

    cmp bl, 0
    je .integer_done

    cmp bl, '0'
    jb .integer_done

    cmp bl, '9'
    ja .integer_done

    imul eax, eax, 10
    sub bl, '0'
    movzx edx, bl
    add eax, edx

    inc esi
    jmp .parse_digit

.integer_done:

    pop edx
    pop esi
    pop ebx

    mov esp, ebp
    pop ebp
    ret

print_uint:

    push ebp
    mov ebp, esp

    push ebx
    push esi
    push edi

    mov eax, [ebp+8]

    test eax, eax
    jnz .convert_number

    push dword zero_text
    call print_string
    add esp, 4
    jmp .number_done

.convert_number:

    mov edi, digit_buffer
    add edi, 15

    mov byte [edi], 0
    mov ebx, 10

.convert_loop:

    xor edx, edx
    div ebx

    add dl, '0'
    dec edi
    mov [edi], dl

    test eax, eax
    jnz .convert_loop

    push edi
    call print_string
    add esp, 4

.number_done:

    pop edi
    pop esi
    pop ebx

    mov esp, ebp
    pop ebp
    ret