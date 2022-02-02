Attribute VB_Name = "Module1"
Sub compare2Worksheets()
'THIS MACRO CAN TAKE 3 - 4 MINUTES TO FINISH RUNNING
Dim ws1row As Long, ws2row As Long, ws1col As Integer, ws2col As Integer
Dim maxrow As Long, maxcol As Integer, cellvalue1 As String, cellvalue2 As String
Dim difference As Long
Dim row As Long, col As Integer
UserForm1.Show
Set report = ThisWorkbook.Worksheets("Results")

Set ws1 = ThisWorkbook.Worksheets("A")
ws1row = ws1.Cells(Rows.Count, "B").End(xlUp).row
ws1col = ws1.UsedRange.Columns.Count

Set ws2 = ThisWorkbook.Worksheets("B")
ws2row = ws2.Cells(Rows.Count, "B").End(xlUp).row
ws2col = ws2.UsedRange.Columns.Count

maxrow = ws1row
maxcol = ws1col
If maxrow < ws2row Then maxrow = ws2row
If maxcol < ws2col Then maxcol = ws2col

report.Activate
Cells.Clear
erow = Cells(Rows.Count, 1).End(xlUp).Offset(1, 0).row

difference = 0

' Loop through each cell to be compared
For col = 1 To maxcol
    For row = 1 To maxrow
    cellvalue1 = ws1.Cells(row, col)
    cellvalue2 = ws2.Cells(row, col)

    ' Handle error from #N/A values
'    If Application.IsNA(ws1.Cells(row, col)) Or Application.IsNA(ws2.Cells(row, col)) Then
'        cellvalue1 = ws1.Cells(row, col).Text
'        cellvalue2 = ws2.Cells(row, col).Text
'    Else
'        cellvalue1 = ws1.Cells(row, col)
'        cellvalue2 = ws2.Cells(row, col)
'    End If
    
' Are there any differences in the cells?
    If cellvalue1 <> cellvalue2 Or ws1.Cells(row, col).Font.Strikethrough <> ws2.Cells(row, col).Font.Strikethrough Or IsEmpty(ws1.Cells(row, col)) <> IsEmpty(ws2.Cells(row, col)) Then
        difference = difference + 1
        Cells(row, col) = "Sheet A:" & Chr(10) & cellvalue1 & Chr(10) & "--------------" & Chr(10) & "Sheet B:" & Chr(10) & cellvalue2
        Cells(row, col).Characters(WorksheetFunction.Find("Sheet A:", Cells(row, col)), Len("Sheet A:")).Font.Bold = True
        Cells(row, col).Characters(WorksheetFunction.Find("Sheet B:", Cells(row, col)), Len("Sheet B:")).Font.Bold = True
        Cells(row, col).Characters(WorksheetFunction.Find("Sheet A:", Cells(row, col)), Len("Sheet A:")).Font.Underline = True
        Cells(row, col).Characters(WorksheetFunction.Find("Sheet B:", Cells(row, col)), Len("Sheet B:")).Font.Underline = True
        Cells(row, col).Interior.Color = RGB(255, 175, 0)
        Cells(row, col).Font.ColorIndex = RGB(0, 0, 0)
' Have contents been strikedthrough?
    If ws1.Cells(row, col).Font.Strikethrough <> ws2.Cells(row, col).Font.Strikethrough Then
        Cells(row, col).Interior.Color = RGB(166, 166, 166)
        If ws1.Cells(row, col).Font.Strikethrough = True Then
            Cells(row, col).Characters(WorksheetFunction.Find(cellvalue1, Cells(row, col)), Len(cellvalue1)).Font.Strikethrough = True
        Else
            Cells(row, col).Characters(WorksheetFunction.Find(cellvalue2, Cells(row, col)), Len(cellvalue2)).Font.Strikethrough = True
        End If
    End If
' Have cells been removed?
    If IsEmpty(ws1.Cells(row, col)) <> IsEmpty(ws2.Cells(row, col)) Then
            Cells(row, col).Interior.Color = RGB(255, 0, 0)
    End If
    End If
Next row

DoEvents
c = Application.WorksheetFunction.RoundDown(col / maxcol * 100, 0)
UserForm1.Label2.Width = c / 100 * 204
UserForm1.Label4.Caption = c & "% complete."
Next col

Unload UserForm1

' Format Results tab
If difference > 0 Then
Columns().ColumnWidth = 10
Range(Cells(1, 1), Cells(maxrow, maxcol)).WrapText = True
Range(Cells(1, 1), Cells(maxrow, maxcol)).Rows.AutoFit
Range(Cells(1, 1), Cells(maxrow, maxcol)).VerticalAlignment = xlVAlignTop
Range(Cells(1, 1), Cells(maxrow, maxcol)).Borders.LineStyle = xlContinuous
End If

' Message Box
MsgBox difference & " cells contain different data.", vbInformation, "Comparison of Sheets A and B"
End Sub


