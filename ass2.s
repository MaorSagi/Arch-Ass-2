section .data  

        result: db "root = %.17e %.17e" , 10, 0
        getEpsilon: db "epsilon = %lf ",10, 0
        getOrder: db "order = %d ",10, 0
        getCoeff: db "coeff %d ", 0
        coeffValueInput: db "= %lf %lf ", 0
        getZn: db "initial = %lf %lf", 0
        ZnR: DQ 0.0
        ZnI: DQ 0.0
        nirmul: DQ 0.0
        nirmulTemp: DQ 0.0
        DivTemp: DQ 0.0
        DerivTemp: DQ 0.0
        mallocation: DQ 0.0
        length: DQ 0.0
        mallocation2: DQ 0.0
        epsilonTwice: DQ 0.0
        tmp2: DQ 0
        
section .bss

        epsilon: resq 1  
        order: resq 1
        power: resq 1
        coeffs: resq 1
        copy: resq 1
        Zn: resq 1
        tmp: resq 1
        epArr: resq 1
        
        
        
section .text 
        
        global main
        extern malloc
        extern printf
        extern scanf
        
        
%macro makeOrderPlus 0
        mov rax, qword [order]
        mov qword[length], rax
        mov rax, 16
        mul qword[length]        
        add rax, 16   
        mov rdi, rax
        call malloc
%endmacro

%macro makeArr2 0
        mov rax, 16
        mov rdi, rax
        call malloc
%endmacro
        
         
        
    main:
        push rbp
	mov rbp, rsp
        
        mov rdi, getEpsilon  
        mov rsi, epsilon    
        mov rax, 0
        call scanf
        
        mov rax, 8
        mov rdi, rax
        call malloc
        mov qword[epArr], rax
        mov rdi, [epArr]
        movq xmm0, [epsilon]
        movq [rdi], xmm0
        
        
        
    
 ;       mov r11, qword [epArr]
 ;       fld qword [r11]
 ;test:  fst qword [r11]
        
        
        mov rdi, getOrder 
        mov rsi, order   
        mov rax, 0
        call scanf
        ; receiving the polynom from the input
        makeOrderPlus
        mov qword[coeffs], rax
        mov r11, qword[length] 
        inc r11     
    
    coeffLoop: ;receiving the coefficient numbers in loop until we reaches the last degree
        mov rdi, getCoeff    
        mov rsi, power     
        mov rax, 0
        call scanf
        
        mov rsi, qword[coeffs]  
        mov rax, 16  
        mov r12, qword [power]
        mul r12
        add rsi, rax         
        mov rdi, coeffValueInput
        lea rsi, [rsi] 
        lea rdx, [rsi + 8]   
        mov rax, 0
        call scanf
        
        dec r11
        cmp r11, 0
        jg coeffLoop
        
        ; receiving the first guess from the input
        mov rdi, getZn
        lea rsi, [ZnR]     
        lea rdx, [ZnI]     
        mov rax, 0
        call scanf
        
        makeArr2
        mov qword[Zn], rax
        mov rdi, [Zn]
        movq xmm0, [ZnR]
        movq xmm1, [ZnI]
        movq [rdi], xmm0
        add rdi, 8
        movq [rdi], xmm1
        
        
        ; receiving the polynom from the input
        makeOrderPlus
        mov qword[copy], rax
        
        makeArr2
        mov qword[tmp], rax
        
        ; putting input arguments in the order that we need 
        mov rdi, [tmp]
        mov rsi, [Zn]
        mov rdx, [coeffs]
        mov rcx, [order]
        mov r8, [copy]
        mov r9, qword [epArr]
        
        call main_nr_loop ; the call for the core of our program
        
        leave
        ret
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;PRINT_Zn;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print:
    enter 0,0
    
    leave
    ret
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;START_CMPLX_ADD;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


cmplx_add:
	push rbp
	mov rbp, rsp
	mov r8,0
	mov r9,0
	mov r8, rdi
	mov r9, rsi

	
	finit
	fld qword [r9]
	fld qword [r8]
	fadd st0, st1
	fst qword [r8]


	fld qword [r9+8]
	fld qword [r8+8]
	fadd st0, st1
	fst qword [r8+8]

	mov     rsp, rbp
        pop     rbp
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;START_CMPLX_SUB;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


cmplx_sub:
	push rbp
	mov rbp, rsp
	mov r8,0
	mov r9,0
	mov r8, rdi
	mov r9, rsi

	
	finit

	fld qword [r9]
	fld qword [r8]
	fsub st0, st1
	fst qword [r8]


	fld qword [r9+8]
	fld qword [r8+8]
	fsub st0, st1
	fst qword [r8+8]

	mov     rsp, rbp
        pop     rbp
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;START_CMPLX_MUL;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


cmplx_mul:
	push rbp
	mov rbp, rsp
	mov r8,0
	mov r9,0
	mov r10,0
	mov r8, rdi
	mov r9, rsi

	
	finit

	fld qword [r9]
	fld qword [r8]
	fmul
	fld qword [r9+8]
	fld qword [r8+8]
	fmul
	fsub
	fst qword [tmp]	;keep value on tmp register

	fld qword [r9]
	fld qword [r8+8]
	fmul
	fld qword [r9+8]
	fld qword [r8]
	fmul
	fadd
	fst qword [r8+8]
	mov r10, [tmp]
	mov qword [r8], r10	


	mov     rsp, rbp
        pop     rbp
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;START_CMPLX_DIV;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


cmplx_div:
	push rbp
	mov rbp, rsp
	mov r8,0
	mov r9,0
	mov r10,0
	mov r8, rdi
	mov r9, rsi

	
	finit

	fld qword [r9]
	fld qword [r8]
	fmul
	fld qword [r9+8]
	fld qword [r8+8]
	fmul
	fadd
	fld qword [r9]
	fld qword [r9]
	fmul
	fld qword [r9+8]
	fld qword [r9+8]
	fmul
	fadd
	fdiv
	fst qword [tmp]	;keep value on tmp register

	fld qword [r9]
	fld qword [r8+8]
	fmul
	fld qword [r9+8]
	fld qword [r8]
	fmul
	fsub
	fld qword [r9]
	fld qword [r9]
	fmul
	fld qword [r9+8]
	fld qword [r9+8]
	fmul
	fadd
	fdiv
	fst qword [r8+8]
	mov r10, [tmp]
	mov qword [r8], r10	

	mov     rsp, rbp
        pop     rbp
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;START_CMPLX_EVAL;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

cmplx_eval:		;gets 4 args (result,x,coeffs,order) 
	push rbp
	mov rbp, rsp
	mov r11,0
	lea r11,[rbp-16]
	mov qword [r11],0
	mov qword [r11+8],0
	push r11	
	push r11

eval_loop:
	push rdi
	push rsi
	push rcx
	push rdx
	push r11
	lea r13, [rcx*8]
	lea r13, [r13*2]
	add rdx, r13	
	mov r8, r11
	call cmplx_fma
	pop r11
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	mov qword [r11],0
	mov qword [r11+8],0
	dec rcx
	cmp rcx, 0
	jge eval_loop
		


	pop r11
	pop r11
	mov     rsp, rbp
        pop     rbp
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;COPY_COEFFS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


copy_coeffs:				;gets 3 args (copy,coeffs,order)
	push rbp
	mov rbp, rsp
	mov r13,0
	mov rcx, rdx
	add rcx, rcx
	inc rcx
	

copy_loop:
	mov r13,qword [rsi]
	mov qword [rdi],r13
	lea rsi, [rsi+8]
	lea rdi, [rdi+8]
	dec rcx
	cmp rcx,0
	jge copy_loop

	mov     rsp, rbp
        pop     rbp
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;START_CMPLX_EVAL_DET;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



cmplx_eval_det:		;gets 4 args (result,x,coeffs,order,copy)
	push rbp
	mov rbp, rsp
	mov r11,0
	lea r11,[rbp-16]
	mov qword [r11],0
	mov qword [r11+8],0
	push r11	;to do
	push r11

	push rdi
	push rsi
	push rcx
	push rdx
	push r8
	push r11
	mov rdi,r8
	mov rsi,rdx
	mov rdx,rcx
	call copy_coeffs
	pop r11
	pop r8		
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	


eval_det_loop:
	cmp rcx,0
	je end_det
	push rdi
	push rsi
	push r11
	push r8
	push rcx
	lea r13, [rcx*8]
	lea r13, [r13*2]
	add r8, r13
	mov rdi, r8 		;coeff
	dec rcx
	cmp rcx,0
	je continue
	mov qword [r11],0
	mov qword [r11+8],0
	mov r12, r8
	copy_coeff:
		mov r13,qword [r12]
		mov qword [r11],r13
		mov r13, qword [r12+8]
		mov qword [r11+8],r13
	pop rcx
	pop r8
	push r8
	push rcx
	lea r13, [rcx*8]
	lea r13, [r13*2]
	add r8, r13
	mov rdi, r8 ;;coeff
	dec rcx
	mov rsi, r11
	det_mul_loop:
		call cmplx_add	
		loop det_mul_loop, rcx

	



continue:
	pop rcx
	pop r8
	pop r11
	pop rsi
	pop rdi
	push rdi
	push rsi
	push rcx
	push r11
	push r8
	mov qword [r11],0
	mov qword [r11+8],0
	lea r13, [rcx*8]
	lea r13, [r13*2]
	add r8, r13
	mov rdx, qword r8
	mov r8, r11
	dec rcx
	call cmplx_fma
	pop r8
	pop r11
	pop rcx
	pop rsi
	pop rdi
	mov qword [r11],0
	mov qword [r11+8],0
	dec rcx
	cmp rcx, 0
	jge eval_det_loop
		


end_det:
	pop r11
	pop r11
	mov     rsp, rbp
        pop     rbp
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;START_CMPLX_FMA;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


fma_zero:
	mov rsi, r10
	call cmplx_add
	jmp end_fma


cmplx_fma:		;gets 5 args (result,x,coeff,order,tmp)
	push rbp
	mov rbp, rsp
	mov r9,0
	mov r10,0
	mov r11,0
	mov r13,0	
	mov r11,r8
	mov r8, rdi
	mov r9, rsi
	mov r10,rdx

copy_x:
	mov r13,qword [r9]
	mov qword [r11],r13
	mov r13, qword [r9+8]
	mov qword [r11+8],r13
	

	cmp rcx,0
	je fma_zero	
	cmp rcx,1
	je fma_one
	

	dec rcx
fma_loop:
	push rdi
	push rsi
	mov rdi,r11
	mov rsi, r9
	call cmplx_mul
	pop rsi
	pop rdi
	mov r8, rdi
	mov r9, rsi
	loop fma_loop,rcx

fma_one:
	push rdi
	push rsi
	mov rdi,r11
	mov rsi, rdx
	call cmplx_mul
	pop rsi
	pop rdi
	mov r8, rdi
	mov r9, rsi
	mov rsi,r11
	call cmplx_add

	
	
end_fma:
	mov     rsp, rbp
        pop     rbp
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;START_CMPLX_NR;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


cmplx_nr:		;gets 3 args (Zn,coeffs,order,copy)
	push rbp
	mov rbp, rsp
	mov r11,0
	mov r12,0 
	sub rsp, 4
	lea r11,[rbp-32]
	lea r12, [rbp-16]
	mov qword [r12],0
	mov qword [r12+8],0
	push r11	;to do
	push r11
	push r12
	push r12




	push rdi
	push rsi
	push rdx
	push rcx
	mov qword [r11],0
	mov qword [r11+8],0
	mov rcx, rdx
	mov rdx, rsi
	mov rsi, rdi 	
	mov rdi, r11
	call cmplx_eval
	pop rcx
	pop rdx
	pop rsi
	pop rdi
	


	push rdi
	push rsi
	push rdx
	push rcx
	lea r12, [rbp-16]
	mov qword [r12],0
	mov qword [r12+8],0
	mov r8,rcx
	mov rcx, rdx
	mov rdx, rsi
	mov rsi, rdi 	
	mov rdi, r12
	call cmplx_eval_det
	pop rcx
	pop rdx
	pop rsi
	pop rdi
	


	push rdi
	push rsi
	push rdx
	push r11
	push r12
	push rcx
	lea r11,[rbp-32]
	lea r12, [rbp-16]	
	mov rdi, r11
	mov rsi, r12 
	call cmplx_div
	pop rcx
	pop r12
	pop r11
	pop rdx
	pop rsi
	pop rdi
	lea r11,[rbp-32]
 

	push rdi
	push rsi
	push rdx
	push rcx
	lea r11,[rbp-32]
	mov rsi, r11	
	call cmplx_sub
	pop rcx
	pop rdx
	pop rsi
	pop rdi
 


	pop r12
	pop r12
	pop r11
	pop r11
	mov     rsp, rbp
        pop     rbp
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;FZ_ABS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

fz_abs:			;gets 1 arg (Z) -> return ||Z||
	push rbp
	mov rbp, rsp
	mov r8, rdi


	fld qword [r8]
	fld qword [r8]
	fmul
	fld qword [r8+8]
	fld qword [r8+8]
	fmul
	fadd
	fsqrt
	fst qword [tmp]	;keep value on tmp register
	mov rax, qword tmp
	

	mov     rsp, rbp
        pop     rbp
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;MAIN_NR_LOOP;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


main_nr_loop:				;gets 6 args (tmp,Zn,coeffs,order,copy,epsilon)
	push rbp
	mov rbp, rsp
	

nr_loop:

	mov qword [rdi],0
	mov qword [rdi+8],0
	push rdi
	push rsi
	push rdx
	push rcx
	push r8
	push r9
	call cmplx_eval
	pop r9
	pop r8
	pop rcx
	pop rdx
	pop rsi
	pop rdi

	push rdi
	push rsi
	push rdx
	push rcx
	push r8
	push r9
	call fz_abs
	pop r9
	pop r8
	pop rcx
	pop rdx
	pop rsi
	pop rdi
	

;	fld qword [rsi]
;test:	fst qword [rsi]	
;	fld qword [rsi+8]	
;        fst qword [rsi+8]
	
	
	fld qword [r9]
       	fld qword [rax]
       	fsub
        fst qword [tmp2] 
        cmp qword [tmp2],0
	jge end_main_nr
	push rdi
	push rsi
	push rdx
	push rcx
	push r8
	push r9
	mov rdi,rsi
	mov rsi,rdx
	mov rdx,rcx
	mov rcx, r8
	call cmplx_nr
	pop r9	
	pop r8
	pop rcx
	pop rdx
	pop rsi
	pop rdi
	
	
	jmp nr_loop
	

end_main_nr:
        fld qword [rsi]
	fst qword [rsi]	
        movsd xmm0, qword[rsi]
        movsd xmm1, qword[rsi+8]
        mov rdi, result
        mov rax, 2
        call printf 
        
	mov     rsp, rbp
        pop     rbp
	ret


