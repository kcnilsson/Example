

/*
        r0               r0        r1             r2          r3
void *mrgSort(unsigned int N, void *bp, unsigned gNxt, unsigned gI)
{



}

*/


#define leftsize r0
#define bp r1
#define gNxt r2
#define gI r3

#define left r4
#define right r5
#define merge r6
#define endmerge r7
#define rightsize r8
#define unitLeft r9
#define unitRight r10
.text
.thumb
.syntax unified
.local N0, N1, LOOP1, DONE, DONETEST, LeftFirst, LoopLeft
.globl mrgSort

mrgSort:


/* if N == 0 branch back to caller*/
   cmp r0, #0    //if N is 0
   bEQ N0        //goto N0
/*if N == 1 */
   cmp r0, #1    //if N is 1
   bEQ N1        //goto N1


/* Beyond this point, N must be greater than 1 */

   /*store caller's registers to stack*/
   push {r4-r7, LR} //store onto stack
   mov r7, r8       //move r8 to r7 to prepare to store onto stack
   push {r7}        //store onto stack
   mov r7, r9       //move r9 to r7
   push {r7}        //store onto stack
   mov r7, r10      //move r10 to r7
   push {r7}        //store onto stack

   /* Set boundaries for the left and right side of the list*/
   lsrs r7, r0, #1        //leftsize = N >> 1 (N/2)
   subs r6, r0, r7        //r6 = N - leftsize
   movs leftsize, r7     //move r7 to leftsize (r0)
   mov rightsize, r6     //rightsize = r6

   /* Prepare for left side recursion 
                 r0     r1   r2   r3
      mrgSort(leftsize, bp, gNxt, gI); */
   bl mrgSort            //call mrgSort
   movs left, r0         //move the returned value to left

   /* Prepare for right side recursion
                 r0      r1   r2    r3
      mrgSort(rightsize, bp, gNxt, gI); */
   mov r0, rightsize    //move rightsize to r0
   bl mrgSort           //call mrgSort
   movs right, r0       //move the returned value to right
   movs leftsize, r7    //move leftsize back to r0

   /* Recursive sort is done,
      onto merging the 2 lists back together 
      bp no longer needed in this section*/ 
   push {r1}           //save bp->next
   ldr r1, [left, gI]  //unitleft = left->len
   mov unitLeft, r1    //update unitleft
   ldr r1, [right, gI] //unitright = right->len
   mov unitRight, r1   //update unitleft
   
   /*
   if(unitright < unitleft){
      endmb = mb = right;
      right = right->next;
      rightsize--;
      if(!rightsize)
         b DONE1
      else
         unitRight = right->len;
   }
   */
   cmp unitRight, unitLeft          //if (unitright < unitleft)
   bGE LeftFirst                    //goto else statement if unitleft is greater or equal
   movs merge, right                //mb = right
   movs endmerge, merge             //endmb = mb
   ldr right, [right, gNxt]         //right = right->next
   mov r1, rightsize                //temporarily store rightsize in r1 
   subs r1, r1, #1                   //rightsize--
   //cmp r1, #0                       //if(rightsize == 0)
   bEQ DONE1                        //branch to done
   mov rightsize, r1                //update rightsize
   ldr r1, [right, gI]              //else unitright = right->len
   mov unitRight, r1                //update unitright
   
   /*
   LOOP for merging
   */
   LOOP1:
      cmp unitRight, unitLeft         //if (unitright < unitleft)
      bGE LoopLeft                    //goto else statement if unitleft is greater or equal
      str right, [endmerge, gNxt]     //endmb->next = right
      ldr endmerge, [endmerge, gNxt]  //endmb = endmb->next  
      ldr right, [right, gNxt]        //right = right->next
      mov r1, rightsize               //temporarily store rightsize onto r1
      subs r1, r1, #1                  //rightsize--
      //cmp r1, #0                      //if(rightsize == 0)
      bEQ DONE1                       //branch to done
      mov rightsize, r1               //update rightsize
      ldr r1, [right, gI]             //else unitright = right->len
      mov unitRight, r1               //update unitright
   b LOOP1                            //loop again
  
/*
   Either left or right is 0 at this point

   if(DONE)
      endmb->next = (leftsize) ? left:right;
*/
   DONE1:
      cmp leftsize, #0                     //if(!leftsize)
      bGT DONETEST                         //merge leftside
      str right, [endmerge, gNxt]          //else merge right side
  
   DONE:
      /* Save bp to r0 for return*/
      movs r0, merge    

      /*load caller's registers before branching back*/
      pop {r1}          //load r1 
      pop {r7}          //load r10 onto r7
      mov r10, r7       //put caller's r10 back
      pop {r7}          //load r9 onto r7
      mov r9, r7        //put caller's r9 back
      pop {r7}          //load r8 onto r7
      mov r8, r7        //put caller's r8 back to register 8
      pop {r4-r7, PC}   //load r4 - r7 and branch back to caller

   DONETEST:
      str left, [endmerge, gNxt]    //endmerge->next = left
      b DONE                        //branch to done
/*
   else{
      endmb = mb = left;
      left = left->next;
      leftsize--;
      if(!leftsize)
         b DONE
      else
         unitleft = left->len;
   }
*/
   LeftFirst:
      movs merge, left                //mb = left
      movs endmerge, merge            //endmb = mb
      ldr left, [left, gNxt]          //left = left->next
      subs leftsize, leftsize, #1      //leftsize--
      //cmp leftsize, #0                //if(leftsize == 0)
      bEQ DONE1                       //branch to DONE
      ldr r1, [left, gI]              //else unitleft = left->len
      mov unitLeft, r1                //update unitLeft
      b LOOP1                         //branch to LOOP1
     
   LoopLeft:
      str left, [endmerge, gNxt]             //endmb->next = left
      ldr endmerge, [endmerge, gNxt]         //endmb = endmb->next  
      ldr left, [left, gNxt]                 //left = left->next
      subs leftsize, leftsize, #1             //leftsiez--
      //cmp leftsize, #0                       //if(leftsize == 0)
      bEQ DONE1                              //branch to done
      ldr r1, [left, gI]                     //else unitleft = left->len
      mov unitLeft, r1                       //update unitLeft
   b LOOP1                                   //and branch back to loop1

 

   N1:
      push {r4-r5}              //store r4, r5 onto stack
      eors r4, r4, r4            //r4 = NULL
      ldr r5, [bp, gNxt]        //load bp->next to r5
      str r4, [bp, gNxt]        //bp->next = NULL
      movs r0, bp               //move bp to r0 for return
      movs bp, r5               //set bp to bp->next
      pop {r4-r5}               //load r4, r5 from stack
      bx LR                     //branch back to caller

   N0:
      movs r0, bp //set base pointer for return
      bx LR       //return back to caller

