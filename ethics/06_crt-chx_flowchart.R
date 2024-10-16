library("DiagrammeR")
library("DiagrammeRsvg")
library("rsvg")

frf <- function(...)
    rprojroot::find_root_file(..., criterion = rprojroot::is_git_root)

graph <- "
    digraph flowchart {
        graph [splines = ortho];

        // consort nodes
        node [shape = box, style = 'rounded,filled', width = 2.5, height = 0.5, fillcolor = '#7589af'];
        Screening [label = 'Screening'];
        Enrollment [label = 'Enrollment'];
        Allocation [label = 'Allocation'];
        FollowUp [label = 'Follow-Up'];
        Analysis [label = 'Analysis'];

        // user nodes
        node [shape = box, style = 'rectangle,filled', width = 2.5, height = 0.5, fillcolor = '#ffaa00'];
        Premed [label = 'Mitarbeitende der\\nPrämedikationsambulanz'];
        GCP1 [label = 'Studienärzt*innen'];
        GCP2 [label = 'Studienärzt*innen'];
        ANI [label = 'Anästhesist*innen'];
        SHK [label = 'Studentische Hilfskräfte'];
        GCP00 [label = 'Studienärzt*innen\nStudentische Hilfskräfte'];
        GCP14 [label = 'Studienärzt*innen\nStudentische Hilfskräfte'];
        ANISONO [label = 'Ultraschallexpert*innen'];
        STAT [label = 'Statistiker*innen'];
        LegendUser [label = 'Mitarbeitende/Rollen'];

        // ultrasound nodes
        node [shape = folder, style = 'filled', width = 2.5, height = 0.5, fillcolor = '#00aa7f'];
        Ultrasound [label = 'Ultraschallvideos\nTag 0 ... Tag 14'];
        LegendUltrasound [label = 'Ultraschalldaten'];

        // redcap nodes
        node [shape = tab, style = 'filled', width = 2.5, height = 0.5, fillcolor = '#550000', fontcolor = '#ffffff'];
        MappingTables [label = 'tab: mapping\\l'];
        AllocationTables [label = 'tab: preop\\l'];
        CrfTables [label = 'tab: crf\\ltab: surgery\\l'];
        FollowUp00Tables [label = 'tab: visite0\\l'];
        FollowUp14Tables [label = 'tab: visite14\\l'];
        MeasurementTables [label = 'tab: measurement0\\l...\\ltab: measurement14\\l'];
        LegendTables [label = 'REDCap Tabellen'];

        // visible nodes
        node [shape = box, style = rectangle, width = 2.5, height = 0.5, fontcolor = '#000000'];
        N1 [label = 'Prüfen der\\nEinschlusskriterien'];
        N2 [label = 'Aufklärung und\\nStudieneinschluss'];
        N3 [label = 'Randomisierung'];
        PaperCrf [label = 'CRF (Papier)'];
        N4 [label = 'Auswertung'];

        // arm 1
        node [shape = box, style = filled, width = 2.5, height = 0.5, fillcolor = '#fdae61']
        CvcInsertionA [label = 'Anlage ZVK'];
        FollowUp00A [label = 'Visite\\nTag 0'];
        FollowUp14A [label = 'Visite\\nTag 14'];

        // arm 2
        node [shape = box, style = filled, width = 2.5, height = 0.5, fillcolor = '#3288bd', fontcolor = '#ffffff']
        CvcInsertionB [label = 'Anlage ZVK'];
        FollowUp00B [label = 'Visite\\nTag 0'];
        FollowUp14B [label = 'Visite\\nTag 14'];

        // plaintext nodes
        node [shape = plaintext, style = rectangle, width = 2.5, height = 0.5, fontcolor = '#000000'];
        T1 [label = 'Einschlusskriterien erfüllt'];
        T2 [label = 'Einwilligung erfolgt'];
        DotsA [label = '...'];
        DotsB [label = '...'];
        DotsC [label = '...'];

        // invisible nodes
        node [shape = box, width = 2.5, height = 0.5, style = invis];
        IScreening1, IScreening2
        IEnrollment1, IEnrollment2
        IAllocation1, IAllocation2
        IPmid
        ICvcInsertion1, ICvcInsertion2
        IFollowUp00
        IFollowUp14
        IDots1, IDots2
        IAnalysis1, IAnalysis2
        ILegend

        // invisible points
        node [shape = point, width = 0, height = 0, style = invis];
        IP1
        IP2
        IP3, IP4, IP5, IP6, IP7, IP8

        // construct diagramm
        {rank = same Screening IScreening1 N1 IScreening2 Premed};
        Screening -> IScreening1 -> N1 -> IScreening2 -> Premed [style = invis];
        N1 -> T1 [arrowhead = none, minlen = 1];
        T1 -> N2 [minlen = 1];

        {rank = same Enrollment IEnrollment1 N2 IEnrollment2 GCP1};
        Enrollment -> IEnrollment1 -> N2 -> IEnrollment2 -> GCP1 [style = invis];
        N2 -> T2 [arrowhead = none, minlen = 1];
        T2 -> N3 [minlen = 1];

        {rank = same Allocation IAllocation1 N3 IAllocation2 GCP2 AllocationTables};
        Allocation -> IAllocation1 -> N3 -> IAllocation2 -> GCP2  [style = invis];
        GCP2 -> MappingTables [minlen = 1];
        GCP2 -> AllocationTables [minlen = 1];

        {rank = same ICvcInsertion1 CvcInsertionA ICvcInsertion2 CvcInsertionB ANI PaperCrf SHK CrfTables};
        ICvcInsertion1 -> CvcInsertionA -> ICvcInsertion2 -> CvcInsertionB -> ANI [style = invis];
        N3 -> IP1 [arrowhead = none, minlen = 1];
        IP1 -> CvcInsertionA [minlen = 1];
        IP1 -> CvcInsertionB [minlen = 1];
        ANI -> PaperCrf [minlen = 1];
        PaperCrf -> SHK [minlen = 1];
        SHK -> CrfTables [minlen = 1];

        {rank = same FollowUp FollowUp00A IFollowUp00 FollowUp00B GCP00 FollowUp00Tables};
        FollowUp -> FollowUp00A -> IFollowUp00 -> FollowUp00B -> GCP00 [style = invis];
        CvcInsertionA -> FollowUp00A [minlen = 1];
        CvcInsertionB -> FollowUp00B [minlen = 1];
        GCP00 -> FollowUp00Tables [minlen = 4];
        FollowUp00Tables -> DotsC [minlen = 1];

        {rank = same IDots1 DotsA IDots2 DotsB};
        IDots1 -> DotsA -> IDots2 -> DotsB [style = invis];
        FollowUp00A -> DotsA [minlen = 1];
        FollowUp00B -> DotsB [minlen = 1];

        {rank = same FollowUp14A IFollowUp14 FollowUp14B GCP14 FollowUp14Tables};
        FollowUp14A -> IFollowUp14 -> FollowUp14B -> GCP14 [style = invis];
        DotsA -> FollowUp14A [minlen = 1];
        DotsB -> FollowUp14B [minlen = 1];
        GCP14 -> FollowUp14Tables [minlen = 1];
        DotsC -> FollowUp14Tables [minlen = 1];

        GCP00 -> Ultrasound [minlen = 1];
        GCP14 -> Ultrasound [minlen = 1];

        {rank = same IP2 Ultrasound ANISONO MeasurementTables};
        Ultrasound -> ANISONO [minlen = 1];
        ANISONO -> MeasurementTables [minlen = 1];

        FollowUp14A -> IP2 [arrowhead = none, minlen = 1];
        FollowUp14B -> IP2 [arrowhead = none, minlen = 1];

        {rank = same Analysis IAnalysis1 N4 STAT};
        Analysis -> IAnalysis1 -> N4 [style = invis];
        IP2 -> N4 [minlen = 1];

        {rank = same AllocationTables IP3};
        AllocationTables -> IP3 [arrowhead = none, minlen = 17];
        IP3 -> CrfTables [arrowhead = none];

        {rank = same FollowUp00Tables IP4};
        FollowUp00Tables -> IP4 [arrowhead = none, minlen = 14];
        CrfTables -> IP4 [arrowhead = none];

        {rank = same FollowUp14Tables IP5};
        FollowUp14Tables -> IP5 [arrowhead = none, minlen = 14];
        IP4 -> IP5 [arrowhead = none];

        {rank = same MeasurementTables IP6};
        MeasurementTables -> IP6 [arrowhead = none, minlen = 1];
        IP5 -> IP6 [arrowhead = none];

        {rank = same N4 STAT IP7};
        IP6 -> IP7 [arrowhead = none];
        STAT -> IP7 [dir = back, minlen = 27];

        {rank = same ILegend LegendUser LegendTables LegendUltrasound}
        STAT -> ILegend [minlen = 2, style = invis];
    }
"
rsvg::rsvg_pdf(
        charToRaw(DiagrammeRsvg::export_svg(grViz(graph))),
        file = frf("ethics", "output", "06_crt-chx_flowchart.pdf")
)

