/* merge part of merge sort (sort is done is C for simplicity)
   This is Arm Assembly Thumb 1 (ARMv4) - no predication in thumb

           r0           r0       r1       r2          r3
   void mrgChains(void *lb, void *rb, uint gNxt, uint gI)
   {
      int unitLeft = lb+gI;
      int unitRight = rb+gI;
      void *merge, *endmerge;

      //initialize merge before loop
      if(unitRight < unitLeft){
         merge = endmerge = rb;
      }
      else{
         merge = endmerge = lb;
      }
      
      do{
         if(unitRight < unitLeft){
            endmerge = rb;
            rb = rb + gNxt;
            if(rb != NULL)
               unitRight = rb + gI;
         }
         else{
            endmerge = lb;
            lb = lb + gNxt;
            if(lb != NULL)
               unitLeft = lb + gI;
         }
         endmerge = endmerge + gNxt
      }while(lb != NULL || rb != NULL);

      endmerge = (lb) ? lb:rb;  //if lb then attach lb else attach rb


      return merge;
   }


*/

#define merge r0
#define rb r1
#define gNxt r2
#define gI r3
#define lb r4
#define unitLeft r5
#define unitRight r6
#define endmerge r7

.text
.thumb
.syntax unified
.local LOOP1
.globl mrgChains

mrgChains:
   push {r4-r7}            //pre-decrement SP and store caller registers
   movs lb, r0                    //store lb (r0) in r4
   ldr unitRight, [rb, gI]       //unitRight = rb + gI
   ldr unitLeft, [lb, gI]        //unitLeft = lb + gI


   /* if unitRight < unitLeft*/
   subs r7, unitRight, unitLeft //r7 = negative:positive
   asrs r7, r7, #31             //check which one r7 = 0:1
   movs r0, rb                   //r0 = rb
   ands r0, r7                  //r0 = (rb < 0) ? rb:0
   mvns r7, r7                  //either all set or none (negate)
   ands r7, lb                  //r7 = (lb >= 0) ? lb : 0 
   orrs merge, r7                  //merge = (unitRight < unitLeft) ? rb:lb
   
   movs endmerge, merge        //endmerge = merge

   /* merge is no longer needed until the end*/
   push {merge}       //pre-increment SP and store merge on stack
   //r0 is now available
   LOOP1:

      /* if unitRight < unitLeft*/
      subs r0, r6, r5 //r0 = negative:positive
      //r5/r6 are available until end of loop
      asrs r0, r0, #31             //check which one r0 = 0:1
      //Determine smallest value
      movs r5, rb                   //r5 = rb
      ands r5, r0                  //r5 = (rb < 0) ? rb:0
      mvns r0, r0                  //either all set or none (negate)
      movs r6, lb                   //r6 = lb
      ands r6, r0                  //r6 = (lb >= 0) ? lb : 0 
      orrs r5, r6                  //r5 = (unitRight < unitLeft) ? rb:lb smallest value
      //Determine largest value
      movs r6, rb                   //r6 = rb
      ands r6, r0                  //r6 = rb:0
      mvns r0, r0                  //r0 = !r0
      ands r0, lb                  //r0 = lb:0
      orrs r6, r0                  //r6 = rb:lb  largest value
      
      movs r0, r5                   //r0 = r5
      ldr r5, [r5, gNxt]           //update either left or right pointer
      str r0, [endmerge, gNxt]     //endmerge->next = prev pointer
      //r0 = prev address; r5 = updated address (possibly null)
      
      //updated address
      movs r1, r5                   //r1 (rb) = r5 (r5 is now determined as right side) arbitrary
      lsls r5, r5, #1              //for very large values shift left one to free the "negative" bit
      subs r5, r5, #1              //r0 = updated address - 1
      asrs r5, r5, #31	           //r0 = 0:1 depending on if updated addr is null or not
      ands r0, r5                  //r0 = prev or 0
      mvns r5, r5                  //r5 = !r5
      ands r5, r1                  //r5 = updated or 0
      orrs r0, r5                  //r0 = prev:updated
      ldr r0, [r0, gI]             //r0 = rb + gI
      //non updated address
      movs r4, r6                   //r4 (lb) = r6 
      ldr r5, [r4, gI]             //r5 = r4->len
      movs r6, r0                  //r6 = r1->len

      movs r0, endmerge            //r0 = endmerge (store prev endmerge)
      ldr endmerge, [endmerge, gNxt] //endmerge = endmerge + gNxt

      //check if updated address is null
      cmp r1, #0                     //if != Null
      
   bNE LOOP1                         // loop again

   //after loop r3, r5, r6 are available for use
   
   movs r3, endmerge       //r3 = endmerge
   lsls r3, r3, #1
   subs r3, r3, #1        //r3 = endmerge - 1
   asrs r3, r3, #31	  //r3 = 0:1 depending if endmerge is null
   ands r0, r3            //r0 = prev-endmerge:0
   mvns r3, r3            //r3 = !r3
   ands r3, endmerge      //r3 = endmerge:0
   orrs r0, r3
   movs endmerge, r0
   
   /* Atleast one element in either lb or rb is left*/
   movs r3, rb         //r3 = rb
   movs r5, lb         //r5 = lb
   bics r3, lb        //r3 = rb:0
   bics r5, rb        //r5 = lb:0
   orrs r3, r5        //r3 = rb:lb
   str r3, [endmerge, gNxt] //endmerge->next = rb:lb
   
   pop {merge} //load merge from stack and increment SP
   pop {r4-r7}  //restore caller register and incrememnt SP
   bx LR               //branch back to caller
