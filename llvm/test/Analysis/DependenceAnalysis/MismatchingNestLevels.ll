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
