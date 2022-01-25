
** this program creates customized template for ODS RTF **;


%macro custom;


ODS PATH work.custom(update) sasuser.templat(read)
               sashelp.tmplmst(read);
ods path show;

proc template;
define style Styles.Custom;
parent = Styles.rtf;

	 	replace fonts /
            'TitleFont2' = ("Courier New", 8pt)
            'TitleFont' = ("Courier New", 8pt)
            'StrongFont' = ("Courier New", 8pt)
            'EmphasisFont' = ("Courier New", 8pt, Bold)
            'FixedEmphasisFont' = ("Courier New", 8pt, Bold)
            'FixedStrongFont' = ("Courier New", 8pt)
            'FixedHeadingFont' = ("Courier New", 8pt)
            'BatchFixedFont' = ("Courier New", 8pt)
            'FixedFont' = ("Courier New", 8pt)
            'headingEmphasisFont' = ("Courier New", 8pt)
            'headingFont' = ("Courier New", 8pt)
            'docFont' = ("Courier New", 8pt);
        style SystemTitle from TitlesAndFooters /
            protectspecialchars=off
            asis=on
            font=Fonts('TitleFont');
        replace Output from Container /
            frame = VOID
            rules = NONE
            background=_undef_
            frameborder=OFF;
        replace color_list /
            'bg' = cxFFFFFF
            'fg' = cx000000;
        replace colors /
            'headerfgemph' = color_list('fg')
            'headerbgemph' = color_list('bg')
            'headerfgstrong' = color_list('fg')
            'headerbgstrong' = color_list('bg')
            'headerfg' = color_list('fg')
            'headerbg' = color_list('bg')
            'datafgemph' = color_list('fg')
            'databgemph' = color_list('bg')
            'datafgstrong' = color_list('fg')
            'databgstrong' = color_list('bg')
            'datafg' = color_list('fg')
            'databg' = color_list('bg')
            'batchfg' = color_list('fg')
            'batchbg' = color_list('bg')
            'tableborder' = color_list('fg')
            'tablebg' = color_list('bg')
            'notefg' = color_list('fg')
            'notebg' = color_list('bg')
            'bylinefg' = color_list('fg')
            'bylinebg' = color_list('bg')
            'captionfg' = color_list('fg')
            'captionbg' = color_list('bg')
            'proctitlefg' = color_list('fg')
            'proctitlebg' = color_list('bg')
            'titlefg' = color_list('fg')
            'titlebg' = color_list('bg')
            'systitlefg' = color_list('fg')
            'systitlebg' = color_list('bg')
            'Conentryfg' = color_list('fg')
            'Confolderfg' = color_list('fg')
            'Contitlefg' = color_list('fg')
            'link2' = color_list('fg')
            'link1' = color_list('fg')
            'contentfg' = color_list('fg')
            'contentbg' = color_list('bg')
            'docfg' = color_list('fg')
            'docbg' = color_list('bg');
        replace Body from Document /


             bottommargin = 0.9in
	         topmargin = 1.0in
             rightmargin = 1.0in
             leftmargin = 1.0in

            pagebreakhtml = html('PageBreakLine');
        replace SystemFooter from TitlesAndFooters /
            font = Fonts('TitleFont')
            just=left
            asis=on
            cellpadding=0
            cellspacing=0;
        style table from output /
            background=_Undef_
            frame=above /* outside borders: void, box, above/below, vsides/hsides, lhs/rhs */
            rules=groups /* internal borders: none, all, cols, rows, groups */
            borderwidth = 0.4pt /* the width of the borders and rules, applies to frame (the outer border) and headline */
            cellpadding = 1   /* the space between table cell contents and the cell border */
            cellspacing = 0   /* the space between table cells, allows background to show */;
        style Header from header /
            background=_undef_
            frame=below
            rules=rows
            font = fonts('HeadingFont')
            foreground = colors('headerfg')
            background = colors('headerbg');
        style Rowheader from Rowheader /
            rules=rows
            background=_undef_
            frame=below;
    end;

run;
%mend;


