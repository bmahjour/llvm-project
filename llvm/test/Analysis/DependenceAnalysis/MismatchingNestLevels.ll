; RUN: opt < %s -disable-output "-passes=print<da>" -aa-pipeline=basic-aa 2>&1 | FileCheck %s

;; void test1(long n, double *A) {
;;     long  i;
;;     for (i = 0; i*n <= n*n; ++i) {
;;         A[i] = i;
;;     }
;;     A[i] = i;
;; }

; CHECK-LABEL: 'Dependence Analysis' for function 'test1':
; CHECK: Src:  store double %conv, ptr %arrayidx, align 8 --> Dst:  store double %conv, ptr %arrayidx, align 8
; CHECK-NEXT:    da analyze - none!
; CHECK: Src:  store double %conv, ptr %arrayidx, align 8 --> Dst:  store double %conv2, ptr %arrayidx3, align 8
; CHECK-NEXT:    da analyze - output [|<]!
; CHECK: Src:  store double %conv2, ptr %arrayidx3, align 8 --> Dst:  store double %conv2, ptr %arrayidx3, align 8
; CHECK-NEXT:    da analyze - none!

define void @test1(i64 noundef %n, ptr nocapture noundef writeonly %A) {
entry:
  %mul1 = mul nsw i64 %n, %n
  br label %for.body

for.body:                                         ; preds = %entry, %for.body
  %i.012 = phi i64 [ 0, %entry ], [ %inc, %for.body ]
  %conv = sitofp i64 %i.012 to double
  %arrayidx = getelementptr inbounds double, ptr %A, i64 %i.012
  store double %conv, ptr %arrayidx, align 8
  %inc = add nuw nsw i64 %i.012, 1
  %mul = mul nsw i64 %inc, %n
  %cmp.not = icmp sgt i64 %mul, %mul1
  br i1 %cmp.not, label %for.end, label %for.body

for.end:                                          ; preds = %for.body
  %conv2 = sitofp i64 %inc to double
  %arrayidx3 = getelementptr inbounds double, ptr %A, i64 %inc
  store double %conv2, ptr %arrayidx3, align 8
  ret void
}


;; int test2(unsigned n, float A[][n+1], float B[n+1]) {
;;   long i, j, k;
;;   int res = 0;
;;   for (i = 0; i <= n; i++) {
;;     for (j = 0; j <= n; j++) {
;;       B[j] = 0;
;;     }
;;     A[i][j] = 1;
;;     for (k = 0; k <= n; k++) {
;;       A[i][k] += 2;
;;     }
;;   }
;;   return res;
;; }
;;
;; Make sure we can detect depnendence between A[i][j] and A[i][k] conservatively and without crashing.

; CHECK-LABEL: 'Dependence Analysis' for function 'test2':
; CHECK: Src:  store float 1.000000e+00, ptr %arrayidx9, align 4 --> Dst:  %5 = load float, ptr %arrayidx16, align 4
; CHECK-NEXT:    da analyze - flow [*|<]!

define signext i32 @test2(i32 noundef zeroext %n, ptr noundef %A, ptr noundef %B) {
entry:
  %add = add i32 %n, 1
  %0 = zext i32 %add to i64
  %1 = zext i32 %n to i64
  %2 = add i64 %1, 1
  br label %for.body

for.body:                                         ; preds = %entry, %for.inc21
  %i.03 = phi i64 [ 0, %entry ], [ %inc22, %for.inc21 ]
  br label %for.body7

for.body7:                                        ; preds = %for.body, %for.body7
  %j.01 = phi i64 [ 0, %for.body ], [ %inc, %for.body7 ]
  %arrayidx = getelementptr inbounds float, ptr %B, i64 %j.01
  store float 0.000000e+00, ptr %arrayidx, align 4
  %inc = add nuw nsw i64 %j.01, 1
  %exitcond = icmp ne i64 %inc, %2
  br i1 %exitcond, label %for.body7, label %for.end

for.end:                                          ; preds = %for.body7
  %inc.lcssa = phi i64 [ %inc, %for.body7 ]
  %3 = mul nuw nsw i64 %i.03, %0
  %arrayidx8 = getelementptr inbounds float, ptr %A, i64 %3
  %arrayidx9 = getelementptr inbounds float, ptr %arrayidx8, i64 %inc.lcssa
  store float 1.000000e+00, ptr %arrayidx9, align 4
  br label %for.body14

for.body14:                                       ; preds = %for.end, %for.body14
  %k.02 = phi i64 [ 0, %for.end ], [ %inc19, %for.body14 ]
  %4 = mul nuw nsw i64 %i.03, %0
  %arrayidx15 = getelementptr inbounds float, ptr %A, i64 %4
  %arrayidx16 = getelementptr inbounds float, ptr %arrayidx15, i64 %k.02
  %5 = load float, ptr %arrayidx16, align 4
  %add17 = fadd fast float %5, 2.000000e+00
  store float %add17, ptr %arrayidx16, align 4
  %inc19 = add nuw nsw i64 %k.02, 1
  %exitcond4 = icmp ne i64 %inc19, %2
  br i1 %exitcond4, label %for.body14, label %for.inc21

for.inc21:                                        ; preds = %for.body14
  %inc22 = add nuw nsw i64 %i.03, 1
  %exitcond5 = icmp ne i64 %inc22, %2
  br i1 %exitcond5, label %for.body, label %for.end23

for.end23:                                        ; preds = %for.inc21
  ret i32 0
}
