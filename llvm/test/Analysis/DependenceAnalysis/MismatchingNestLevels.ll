; RUN: opt < %s -disable-output "-passes=print<da>" -aa-pipeline=basic-aa 2>&1 | FileCheck %s

; CHECK-LABEL: 'Dependence Analysis' for function 'test1':
; CHECK: Src:  %src = load double, double* %arrayidx295, align 8 --> Dst:  %src = load double, double* %arrayidx295, align 8
; CHECK-NEXT:    da analyze - consistent input [S 0]!
; CHECK: Src:  %src = load double, double* %arrayidx295, align 8 --> Dst:  %1 = load double, double* %arrayidx98, align 8
; CHECK-NEXT:    da analyze - input [*|<]!
; CHECK: Src:  %1 = load double, double* %arrayidx98, align 8 --> Dst:  %1 = load double, double* %arrayidx98, align 8
; CHECK-NEXT:    da analyze - input [*]!

define dso_local void @test1([512 x double]* %temp) local_unnamed_addr {
entry:
  br label %for.cond1.preheader

for.cond1.preheader:                              ; preds = %for.end63, %entry
  br label %for.body272

for.body272:                                      ; preds = %for.body272, %for.cond1.preheader
  %r.1597 = phi i32 [ 1, %for.cond1.preheader ], [ %add277, %for.body272 ]
  %idxprom274 = zext i32 %r.1597 to i64
  %add277 = add nuw nsw i32 %r.1597, 1
  %arrayidx295 = getelementptr inbounds [512 x double], [512 x double]* %temp, i64 %idxprom274, i64 510
  %src = load double, double* %arrayidx295, align 8
  br i1 undef, label %for.body272, label %for.body6

for.body6:                                        ; preds = %for.body6, %for.body272
  %c.2594 = phi i32 [ 1, %for.body272 ], [ %add27, %for.body6 ]
  %add27 = add nuw nsw i32 %c.2594, 1
  br i1 undef, label %for.body6, label %for.end63

for.end63:                                        ; preds = %for.body6
  %c.1.lcssa = phi i32 [ %add27, %for.body6 ]
  %sub96 = add nsw i32 %c.1.lcssa, -1
  %0 = zext i32 %sub96 to i64
  %arrayidx98 = getelementptr inbounds [512 x double], [512 x double]* %temp, i64 0, i64 %0
  %1 = load double, double* %arrayidx98, align 8
  br label %for.cond1.preheader
}

; CHECK-LABEL: 'Dependence Analysis' for function 'test2':
; CHECK: Src: %1 = load double, double* %arrayidx98, align 8 --> Dst:  %1 = load double, double* %arrayidx98, align 8
; CHECK-NEXT:   da analyze - input [*]!
; CHECK: Src: %1 = load double, double* %arrayidx98, align 8 --> Dst:  %2 = load double, double* %arrayidx295, align 8
; CHECK-NEXT:   da analyze - input [*|<]!
; CHECK: Src: %2 = load double, double* %arrayidx295, align 8 --> Dst:  %2 = load double, double* %arrayidx295, align 8
; CHECK-NEXT:   da analyze - consistent input [S 0]!

define dso_local void @test2([512 x double]* %temp) local_unnamed_addr #0 {
entry:
  br label %for.cond1.preheader

for.cond1.preheader:                              ; preds = %for.body272, %entry
  br label %for.body6

for.body6:                                        ; preds = %for.body6, %for.cond1.preheader
  %c.2594 = phi i32 [ 1, %for.cond1.preheader ], [ %add27, %for.body6 ]
  %add27 = add nuw nsw i32 %c.2594, 1
  br i1 undef, label %for.body6, label %for.end63

for.end63:                                        ; preds = %for.body6
  %c.1.lcssa = phi i32 [ %add27, %for.body6 ]
  %sub96 = add nsw i32 %c.1.lcssa, -1
  %0 = zext i32 %sub96 to i64
  %arrayidx98 = getelementptr inbounds [512 x double], [512 x double]* %temp, i64 0, i64 %0
  %1 = load double, double* %arrayidx98, align 8
  br label %for.body272

for.body272:                                      ; preds = %for.body272, %for.end63
  %r.1597 = phi i32 [ 1, %for.end63 ], [ %add277, %for.body272 ]
  %idxprom274 = zext i32 %r.1597 to i64
  %add277 = add nuw nsw i32 %r.1597, 1
  %arrayidx295 = getelementptr inbounds [512 x double], [512 x double]* %temp, i64 %idxprom274, i64 510
  %2 = load double, double* %arrayidx295, align 8
  br i1 undef, label %for.body272, label %for.cond1.preheader
}


;; void test3(long n, double *A) {
;;     long  i;
;;     for (i = 0; i*n <= n*n; ++i) {
;;         A[i] = i;
;;     }
;;     A[i] = i;
;; }

; CHECK-LABEL: 'Dependence Analysis' for function 'test3':
; CHECK: Src:  store double %conv, ptr %arrayidx, align 8 --> Dst:  store double %conv, ptr %arrayidx, align 8
; CHECK-NEXT:    da analyze - none!
; CHECK: Src:  store double %conv, ptr %arrayidx, align 8 --> Dst:  store double %conv2, ptr %arrayidx3, align 8
; CHECK-NEXT:    da analyze - output [|<]!
; CHECK: Src:  store double %conv2, ptr %arrayidx3, align 8 --> Dst:  store double %conv2, ptr %arrayidx3, align 8
; CHECK-NEXT:    da analyze - none!

define void @test3(i64 noundef %n, ptr nocapture noundef writeonly %A) {
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
