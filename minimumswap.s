        .data
#  storing required data into memory
array:  .word 67 43 3 7 2 35 9 62 4 8

        .text
        .globl main
main:   
        add     $t1, $zero, $zero   # i (index) = 0
        add     $s0, $zero, $zero   # base address =0
        # initializing minimum =  storing a[0] value in minimum
        lw      $t0, 0($s0)         
        add     $t7, $zero, $zero    # index of minimum
        # j (index) = 0 for printing updated array
        add     $t9, $zero, $zero
        addi    $s1, $zero, 10         

loop:   slt    $t3, $t1, $s1         # if i == 10 goto done
        beq     $t3, $zero, swapmin
        add     $t6, $t1, $zero        # offset = index 
        add     $t5, $s0, $t6       # address = base_address + offset;
        lw      $t4, 0($t5)         # t4= arr[i]
        slt     $t2, $t4, $t0       # setting less than in t2
        # switching to min branch if a[i]<current_min
        bne     $t2, $zero, min     
# label b_loop for returning after min has been updated
b_loop: addi    $t1, $t1, 1         # i++
        j       loop
# min updates the minimum value and the index containing it
min:    add     $t0, $zero, $t4     # updating minimum value
        # updating index of minimum so that we can swap values letter
        add     $t7, $zero, $t1     
        j      b_loop
# for swapping the minimum and last array
swapmin:   
        lw      $t4,  9($s0)     # saving the last value of the array
        add     $t6, $t7, $zero        # offset = min_index *4
        sw      $t0, 9($s0)        # storing min value in last position
        add     $t5, $s0, $t6       # min_address = base + offset
        # storing the value of last element in the position of minimum value
        sw      $t4, 0($t5)         
        j       done          # to print the updated array


done:
        add $t0, $zero, $zero
        jr $ra                      # return from main
        