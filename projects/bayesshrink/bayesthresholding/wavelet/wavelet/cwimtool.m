function varargout = cwimtool(option,varargin)
%CWIMTOOL Complex Continuous Wavelet 1-D tool.
%   VARARGOUT = CWIMTOOL(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 17-May-99.
%   Last Revision: 16-Jan-2001.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/06/17 12:19:31 $

% Test inputs.
%-------------
if nargin==0 , option = 'create'; end
[option,winAttrb] = utguidiv('ini',option,varargin{:});

% Default values.
%----------------
max_lev_anal = 12;
default_nbcolors = 128;

% Memory bloc of stored values.
%==============================
% MB0.
%-----
n_InfoInit   = 'InfoInit';
ind_filename = 1;
ind_pathname = 2;
nb0_stored   = 2;

% MB1.
%-----
n_param_anal   = 'Par_Anal';
ind_sig_name   = 1;
ind_sig_size   = 2;
ind_wav_name   = 3;
ind_lev_anal   = 4;
ind_act_option = 5;
ind_gra_area   = 6;
nb1_stored     = 6;

% MB2.
%-----
n_coefs_sca    = 'Coefs_Scales';
ind_coefs      = 1;
ind_scales     = 2;
ind_frequences = 3;
ind_sca_OR_frq = 4;
nb2_stored     = 4;

switch option
    case 'create'

        % Get Globals.
        %-------------
        [Def_Txt_Height,Def_Btn_Height,Def_Btn_Width,  ...
         Pop_Min_Width,X_Spacing,Y_Spacing,            ...
         Def_TxtBkColor,Def_EdiBkColor,Def_FraBkColor  ...
         ] = mextglob('get',...
              'Def_Txt_Height','Def_Btn_Height','Def_Btn_Width', ...
              'Pop_Min_Width','X_Spacing','Y_Spacing',           ...
              'Def_TxtBkColor','Def_EdiBkColor','Def_FraBkColor' ...
              );

        % window creation.
        %-----------------
        win_title = 'Complex Continuous Wavelet 1-D';
        [win_tool,pos_win,win_units,str_numwin,...
            fra_hdl,pos_fra,Pos_Graphic_Area,pus_close] = ...
               wfigmngr('create',win_title,winAttrb,...
                  'ExtFig_Tool_3',mfilename,1,1,0);
        if nargout>0 , varargout{1} = win_tool; end
		
		% Add Help for Tool.
		%------------------
		wfighelp('addHelpTool',win_tool,'&Complex Continuous Analysis','CWIM_GUI');

		% Add Help Item.
		%----------------
		wfighelp('addHelpItem',win_tool,'Continuous Transform','CW_TRANSFORM');
		wfighelp('addHelpItem',win_tool,'Continuous Versus Discrete (1)','CW_CONTDISC1');	
		wfighelp('addHelpItem',win_tool,'Continuous Versus Discrete (2)','CW_CONTDISC2');		
		wfighelp('addHelpItem',win_tool,'Loading and Saving','CW_LOADSAVE');
		
		% Set 'WindowButtonUpFcn' function.
		%---------------------------------
		cb_up = ['cw1dmngr(''WindowButtonUpFcn'',' str_numwin ')'];
		set(win_tool,'WindowButtonUpFcn',cb_up);
		
        % Menu construction for current figure.
        %--------------------------------------
	    m_files = wfigmngr('getmenus',win_tool,'file');	
        men_load = uimenu(m_files,...
                         'Label','&Load Signal ', ...
                         'Position',1,           ...
                         'Callback',             ...
                         ['cw1dmngr(''load'',' str_numwin ');'] ...
                         );

        men_save = uimenu(m_files,...
                         'Label','&Save Coefficients ',...
                         'Position',2,                ...
                         'Enable','Off',              ...
                         'Callback',                  ...
                          ['cw1dmngr(''save'',' str_numwin ');'] ...
                          );

        men_demo = uimenu(m_files,...
                         'Label','&Example Analysis ','Position',3);

        demoSET = {...
          'Test Singuralities (I)' , ...
              'cuspamax' , 'cgau2'       , 1 , [1,1,64] , 128 ; ...
          'Test Singuralities (II)' , ...
              'cuspamax' , 'cgau4'       , 1 , [1,1,64] , 128 ; ...
          'Test Singuralities (III)' , ...
              'cuspamax' , 'shan1-1.5'   , 1 , [1,1,64] , 128 ; ...
          'Near Breaks (I)' , ...
              'brkintri' , 'cmor1-0.1'   , 1 , [1,1,64] , 128 ; ...
          'Near Breaks (II)' , ...
              'brkintri' , 'cgau4'       , 1 , [1,1,64] , 128 ; ...
          'Symmetric Cantor curve' , ...
              'wcantsym' , 'cgau1'       , 1 , [1,1,64] , 128 ; ...
          'Noisy sine' , ...
              'noissin'  , 'cgau2'       , 2 , [1,1,48] , 128   ...
          };
        beg_call_str = ['cw1dmngr(''demo'',' str_numwin ','''];
        nbDEM = size(demoSET,1);
        for k=1:nbDEM
            nam  = demoSET{k,1};
            fil  = demoSET{k,2};
            wav  = demoSET{k,3};
            colm = demoSET{k,4};
            val  = demoSET{k,5};
            nbcol = demoSET{k,6};
            scales = ['[' num2str(val(1)) ':' num2str(val(2)) ...
                            ':' num2str(val(3)) ']'];
            libel = ['with ' wav '   at scales  ' scales ...
                            '  -->  ' nam];
            action = [beg_call_str fil ''',''' wav ''','  ...
                    num2str(val(1)) ',' num2str(val(2)) ',' ...
                    num2str(val(3)) ',' sprintf('%.0f',colm) ',' ...
                    int2str(nbcol) ');'];
            uimenu(men_demo,'Label',libel,'Callback',action);
        end

        % Begin waiting.
        %---------------
        wwaiting('msg',win_tool,'Wait ... initialization');

        % General graphical parameters initialization.
        %--------------------------------------------
        x_frame   = pos_fra(1);
        cmd_width = pos_fra(3);
        dx = X_Spacing;
        dy = Y_Spacing; dy2 = 2*dy;        
        d_txt = (Def_Btn_Height-Def_Txt_Height);
        pop_width = pos_fra(3)-8*dx;

        % Command part of the window.
        %============================
        % Data, Wavelet and Level parameters.
        %------------------------------------
        xlocINI = pos_fra([1 3]);
        ytopINI = pos_win(4)-dy;
        toolPos = utanapar('create',win_tool, ...
                    'levflag',0, ...
                    'xloc',xlocINI,'top',ytopINI,...
                    'enable','off', ...
                    'wtype','ccwt', ...
                    'maxlev',max_lev_anal  ...
                    );

        % Adding colormap GUI.
        %---------------------
        utcolmap('create',win_tool, ...
                 'xloc',xlocINI, ...
                 'enable','off', ...
                 'bkcolor',Def_FraBkColor);
        colmapPos = utcolmap('position',win_tool);

        % Setting Initial Colormap.
        %--------------------------
        cbcolmap('set',win_tool,'pal',{'pink',default_nbcolors})

        % UIC construction.
        %------------------------------------------------------------------
        y_low       = toolPos(2);
        h_fra       = Def_Btn_Height+2*dy;
        y_fra       = y_low-h_fra-1.5*dy;
        pos_fra_sam = [toolPos(1),y_fra,toolPos(3),h_fra];
        y_low       = pos_fra_sam(2)+dy;
        x_uic       = toolPos(1)+dx;
        w_uic       = Pop_Min_Width;
        pos_txt_sam = [x_uic, y_low+d_txt/2, 2*w_uic, Def_Txt_Height];
        x_uic       = x_uic+pos_txt_sam(3);
        pos_edi_sam = [x_uic, y_low , w_uic, Def_Btn_Height] ;      
        %------------------------------------------------------------------
        h_fra       = 4*Def_Btn_Height+7*dy;
        y_fra       = pos_fra_sam(2)-h_fra-3*dy;
        pos_fra_sca = [toolPos(1),y_fra,toolPos(3),h_fra];
        y_low       = y_fra+dy;
        %------------------------------------------------------------------
        x_left_1    = x_frame+2*dx;
        x_left_2    = x_frame+(cmd_width-pop_width)/2;
        y_uic       = pos_fra_sca(2)+pos_fra_sca(4)-dy;
        w_uic       = 1.5*Pop_Min_Width;        
        x_uic       = toolPos(1)+(toolPos(3)-w_uic)/2;
        pos_txt_sca = [x_uic, y_uic, w_uic, Def_Txt_Height];
        y_low       = pos_txt_sca(2)-Def_Btn_Height-dy;
        pos_pop_sca = [x_left_2, y_low, pop_width, Def_Btn_Height];
        %------------------------------------------------------------------
        deltay      = Def_Btn_Height+dy;
        w_txt       = pos_pop_sca(3)/2+2*dx;
        w_edi       = pos_pop_sca(3)/2-2*dx;
        y_low       = pos_pop_sca(2)-Def_Btn_Height-dy2;
        pos_txt_min = [x_left_1, y_low+d_txt/2, w_txt, Def_Txt_Height];
        pos_edi_min = [x_left_1+w_txt, y_low, w_edi, Def_Btn_Height];
        pos_txt_stp = pos_txt_min; pos_txt_stp(2) = pos_txt_stp(2)-deltay;
        pos_edi_stp = pos_edi_min; pos_edi_stp(2) = pos_edi_stp(2)-deltay;
        pos_txt_max = pos_txt_stp; pos_txt_max(2) = pos_txt_max(2)-deltay;
        pos_edi_max = pos_edi_stp; pos_edi_max(2) = pos_edi_max(2)-deltay;
        %------------------------------------------------------------------
        w_txt       = (2*Def_Btn_Width)/3;
        pos_txt_pow = [x_left_1, y_low+d_txt/2, w_txt, Def_Txt_Height];
        xl          = pos_txt_pow(1)+pos_txt_pow(3)+dx;
        pos_pop_pow = [xl, y_low, Pop_Min_Width, Def_Btn_Height];
        %------------------------------------------------------------------
        pos_txt_msc = [x_left_1, y_low , pos_pop_sca(3), Def_Txt_Height];
        y_low       = y_low-Def_Btn_Height-dy;
        pos_edi_msc = [x_left_2, y_low , pos_pop_sca(3), Def_Btn_Height];
        %------------------------------------------------------------------
        w_uic       = 1.5*Def_Btn_Width;
        y_uic       = 1.5*Def_Btn_Height;
        y_low       = pos_fra_sca(2)-y_uic-2*dy;
        x_uic       = toolPos(1)+(toolPos(3)-w_uic)/2;
        pos_pus_ana = [x_uic,y_low,w_uic,y_uic];
        %------------------------------------------------------------------

        %------------------------------------------------------------------
        y_fra       = colmapPos(2)+colmapPos(4)+2*dy;
        h_fra       = Def_Btn_Height+3*dy;        
        pos_fra_ccm = [toolPos(1),y_fra,toolPos(3),h_fra];
        y_low       = y_fra+dy;
        pos_pop_ccm = [toolPos(1)+dx,y_low,toolPos(3)-2*dx,Def_Btn_Height];
        y_low       = y_low+Def_Btn_Height+dy/2;
        w_uic       = 1.5*Def_Btn_Width;
        x_uic       = toolPos(1)+(toolPos(3)-w_uic)/2;
        pos_txt_ccm = [x_uic, y_low, w_uic, Def_Txt_Height];
        %------------------------------------------------------------------
        y_low       = pos_fra_ccm(2)+pos_fra_ccm(4)+3*dy;
        x_uic       = toolPos(1);
        w_uic       = (toolPos(3)-dx)/2;
        pos_rad_SCA = [x_uic, y_low, w_uic, Def_Btn_Height];
        x_uic       = x_uic+w_uic+dx;
        pos_rad_FRQ = [x_uic, y_low, w_uic, Def_Btn_Height];
        %------------------------------------------------------------------
        y_fra       = pos_rad_SCA(2)+pos_rad_SCA(4)+dy2;
        h_fra       = 4*Def_Btn_Height+4*dy;
        w_uic       = 2*Def_Btn_Width;
        w_fra       = toolPos(3);
        x_fra       = toolPos(1); 

        pos_fra_axe = [x_fra,y_fra,w_fra,h_fra];
        y_low       = y_fra+dy;
        x_uic       = toolPos(1)+(toolPos(3)-w_uic)/2; 
        pos_chk_LML = [x_uic, y_low, w_uic, Def_Btn_Height];
        y_low       = y_low+Def_Btn_Height;
        pos_chk_LC  = [x_uic, y_low, w_uic, Def_Btn_Height];
        y_low       = y_low+Def_Btn_Height;
        pos_chk_DEC = [x_uic, y_low, w_uic, Def_Btn_Height];
        
        y_low       = y_low+Def_Btn_Height+dy;
        w_uic       = (w_fra-2*dx)/4;
        x_uic       = x_fra+dx;
        pos_rad_MOD = [x_uic, y_low, 1.5*w_uic, Def_Btn_Height];
        x_uic       = x_uic+1.5*w_uic;
        pos_rad_ANG = [x_uic, y_low, 1.5*w_uic, Def_Btn_Height];
        x_uic       = x_uic+1.5*w_uic;
        pos_rad_ALL = [x_uic, y_low, w_uic, Def_Btn_Height];
        
        y_low       = y_low+Def_Btn_Height;
        w_uic       = 1.25*Def_Btn_Width;
        x_uic       = toolPos(1)+(toolPos(3)-w_uic)/2; 
        pos_txt_axe = [x_uic, y_low, w_uic, Def_Txt_Height];
        %------------------------------------------------------------------
        y_low       = pos_fra_axe(2)+pos_fra_axe(4)+2*dy2;
        xg          = x_frame+(cmd_width-pop_width)/2;
        pos_pus_ref = [xg,y_low,pop_width,Def_Btn_Height];
        y_low       = y_low+Def_Btn_Height;
        pos_pus_lin = [xg,y_low,pop_width,Def_Btn_Height];
        %------------------------------------------------------------------

        % String property of objects.
        %----------------------------
        str_txt_sam = 'Sampling Period:';
        str_txt_sca = 'Scale Settings';
        str_pop_sca = ...
            strvcat('Step by Step Mode','Power 2 Mode','Manual Mode');
        str_pus_ana = 'Analyze';
        str_pus_lin = 'New Coefficients Line';
        str_pus_ref = 'Refresh Maxima Lines';

        str_txt_min = 'Min  ( > 0)';
        str_txt_stp = 'Step ( > 0 )';
        str_txt_max = 'Max     ';

        str_txt_pow = 'Power';
        str_pop_pow = int2str([1:max_lev_anal]');
        str_txt_msc = 'Scales : MATLAB Vector';

        str_txt_axe = 'Selected Axes';
        str_rad_MOD = 'Modulus';
        str_rad_ANG = 'Angle';
        str_rad_ALL = 'Both';
        str_chk_LML = 'Maxima Lines';
        str_chk_LC  = 'Coefficients Line';
        str_chk_DEC = 'Coefficients';

        str_rad_SCA = 'Scales';
        str_rad_FRQ = 'Frequencies';

        str_txt_ccm = 'Coloration Mode';
        str_pop_ccm = ['init + by scale     '; ...
                       'init + all scales   '; ...
                       'current + by scale  '; ...
                       'current + all scales'     ];


        % Callback property of objects.
        %------------------------------
        cba_edi_sam = ['cw1dmngr(''setSamPer'',' str_numwin ');'];
        cba_pus_ana = ['cw1dmngr(''anal'',' str_numwin ');'];
        cba_pus_lin = ['cw1dmngr(''newCfsLine'',' str_numwin ');'];
        cba_pus_ref = ['cw1dmngr(''newChainLine'',' str_numwin ');'];
        cba_pop_sca = ['cw1dmngr(''newScaleMode'',' str_numwin ');'];
        cba_axe_RAD = ['cw1dmngr(''setPosAxesIMAG'',' str_numwin ');'];
        cba_axe_CHK = ['cw1dmngr(''setPosAxes'',' str_numwin ');'];
        cba_sof_RAD = ['cw1dmngr(''sca_OR_frq'',' str_numwin ');'];
        cba_pop_ccm = ['cw1dmngr(''colorCoefs'',' str_numwin ');'];
 
        % UIC common properties.
        %-----------------------
        comPropINI = {...
           'Parent',win_tool, ...
           'Unit',win_units,  ...
           };        
        comPropAll = {comPropINI{:},'Visible','On'};
        comPropFra = {comPropAll{:},       ...
           'Style','frame',                 ...
           'Backgroundcolor',Def_FraBkColor...
           };
        comPropTxtLEFT = {comPropAll{:},   ...
           'Style','text',                 ...
           'HorizontalAlignment','left',   ...
           'Backgroundcolor',Def_FraBkColor...
           };
        comPropTxtCENT = {comPropAll{:},   ...
           'Style','text',                 ...
           'HorizontalAlignment','center', ...
           'Backgroundcolor',Def_FraBkColor...
           };
        comPropEdi = {comPropAll{:},       ...
           'Style','edit',                 ...
           'Enable','Off',                 ...
           'HorizontalAlignment','center', ...
           'Backgroundcolor',Def_EdiBkColor...
           };
        comPropChk = {comPropAll{:},       ...
           'Style','CheckBox',             ...
           'Enable','Off',                 ...
           'HorizontalAlignment','center', ...
           'Backgroundcolor',Def_FraBkColor...
           };
        comPropRad = {comPropAll{:},       ...
           'Style','RadioButton',          ...
           'Enable','Off',                 ...
           'HorizontalAlignment','center', ...
           'Backgroundcolor',Def_FraBkColor...
           };

        % UIC construction.
        %------------------
        %-----------------------------------------------------------------%
        fra_sam = uicontrol(comPropFra{:},'Position',pos_fra_sam);
        txt_sam = uicontrol(comPropTxtLEFT{:},              ...
                            'Position',pos_txt_sam,         ...
                            'HorizontalAlignment','center', ...
                            'String',str_txt_sam            ...
                            );
        edi_sam = uicontrol(comPropEdi{:}, ...
                            'Position',pos_edi_sam, ...
                            'CallBack',cba_edi_sam);
        %-----------------------------------------------------------------%
        fra_sca = uicontrol(comPropFra{:},          ...
                            'Position',pos_fra_sca, ...
                            'TooltipString','Scale Settings'  ...
                            );

        txt_sca = uicontrol(comPropTxtCENT{:},      ...
                            'Position',pos_txt_sca, ...
                            'String',str_txt_sca    ...
                            );
        sca_mod = 1;
        pop_sca = uicontrol(comPropAll{:},          ...
                            'Style','Popup',        ...
                            'Position',pos_pop_sca, ...
                            'String',str_pop_sca,   ...
                            'Value',sca_mod ,       ...
                            'UserData',0,           ...
                            'Enable','Off',         ...
                            'Callback',cba_pop_sca  ...
                             );

        pus_ana = uicontrol(comPropAll{:},          ...
                            'Style','Pushbutton',   ...
                            'Position',pos_pus_ana, ...
                            'String',xlate(str_pus_ana),   ...
                            'Enable','Off',         ...
                            'Callback',cba_pus_ana, ...
                            'Interruptible','On'    ...
                            );

        %-------------------------- Mode Step by Step --------------------%
        txt_min = uicontrol(comPropTxtLEFT{:},      ...
                            'Position',pos_txt_min, ...
                            'String',str_txt_min    ...
                            );

        edi_min = uicontrol(comPropEdi{:},'Position',pos_edi_min);

        txt_stp = uicontrol(comPropTxtLEFT{:},      ...
                            'Position',pos_txt_stp, ...
                            'String',str_txt_stp    ...
                            );

        edi_stp = uicontrol(comPropEdi{:},'Position',pos_edi_stp);

        txt_max = uicontrol(comPropTxtLEFT{:},      ...
                            'Position',pos_txt_max, ...
                            'String',str_txt_max    ...
                            );

        edi_max = uicontrol(comPropEdi{:},'Position',pos_edi_max);
        %--------------------------- Mode Power 2-------------------------%
        txt_pow = uicontrol(comPropTxtLEFT{:},      ...
                            'Visible','Off',        ...
                            'Position',pos_txt_pow, ...
                            'String',str_txt_pow    ...
                            );

        pop_pow = uicontrol(comPropAll{:},          ...
                            'Style','Popup',        ...
                            'Visible','Off',        ...
                            'Position',pos_pop_pow, ...
                            'String',str_pop_pow,   ...
                            'Enable','off'          ...
                            );
        %-------------------------- Mode Manual --------------------------%
        txt_msc = uicontrol(comPropTxtLEFT{:},      ...
                            'Visible','Off',        ...
                            'Position',pos_txt_msc, ...
                            'String',str_txt_msc    ...
                            );

        edi_msc = uicontrol(comPropEdi{:},          ...
                            'Visible','Off',        ...
                            'Position',pos_edi_msc, ...
                            'String','[1:2:64]'     ...
                            );
        %-----------------------------------------------------------------%
        fra_axe = uicontrol(comPropFra{:},'Position',pos_fra_axe);
        txt_axe = uicontrol(comPropTxtCENT{:},      ...
                            'Position',pos_txt_axe, ...
                            'String',str_txt_axe    ...
                            );

        rad_MOD = uicontrol(comPropRad{:},          ...
                            'Position',pos_rad_MOD, ...
                            'String',str_rad_MOD,   ...
                            'Value',0,              ...
                            'Callback',cba_axe_RAD  ...
                            );
        rad_ANG = uicontrol(comPropRad{:},          ...
                            'Position',pos_rad_ANG, ...
                            'String',str_rad_ANG,   ...
                            'Value',0,              ...
                            'Callback',cba_axe_RAD  ...                            
                            );

        rad_ALL = uicontrol(comPropRad{:},          ...
                            'Position',pos_rad_ALL, ...
                            'String',str_rad_ALL,   ...
                            'Value',1,              ...
                            'Callback',cba_axe_RAD  ...                            
                            );

        chk_DEC = uicontrol(comPropChk{:},          ...
                            'Position',pos_chk_DEC, ...
                            'String',str_chk_DEC,   ...
                            'Value',1,              ...
                            'Callback',cba_axe_CHK  ...
                            );
        chk_LC  = uicontrol(comPropChk{:},          ...
                            'Position',pos_chk_LC,  ...
                            'String',str_chk_LC,    ...
                            'Value',1,              ...
                            'Callback',cba_axe_CHK  ...
                            );
        chk_LML = uicontrol(comPropChk{:},          ...
                            'Position',pos_chk_LML, ...
                            'String',str_chk_LML,   ...
                            'Value',1,              ...
                            'Callback',cba_axe_CHK  ...
                            );       
        pus_lin = uicontrol(comPropAll{:},          ...
                            'Style','Pushbutton',   ...
                            'Position',pos_pus_lin, ...
                            'String',xlate(str_pus_lin),   ...
                            'Enable','Off',         ...
                            'Callback',cba_pus_lin, ...
							'Tooltip','New Coefficients Line', ...
                            'Interruptible','On'    ...
                            );
        pus_ref = uicontrol(comPropAll{:},          ...
                            'Style','Pushbutton',   ...
                            'Position',pos_pus_ref, ...
                            'String',xlate(str_pus_ref),   ...
                            'Enable','Off',         ...
                            'Callback',cba_pus_ref, ...
							'Tooltip','Refresh Maxima Lines', ...
                            'Interruptible','On'    ...
                            );
		%-----------------------------------------------------------------%
        rad_SCA = uicontrol(comPropRad{:},          ...
                            'Position',pos_rad_SCA, ...
                            'String',str_rad_SCA,   ...
                            'Value',1,              ...
                            'Callback',cba_sof_RAD  ...
                            );
        rad_FRQ = uicontrol(comPropRad{:},          ...
                            'Position',pos_rad_FRQ, ...
                            'String',str_rad_FRQ,   ...
                            'Value',0,              ...
                            'Callback',cba_sof_RAD  ...                            
                            );
        %-----------------------------------------------------------------%
        fra_ccm = uicontrol(comPropFra{:},'Position',pos_fra_ccm);

        txt_ccm = uicontrol(comPropTxtCENT{:},      ...
                            'Position',pos_txt_ccm, ...
                            'String',str_txt_ccm    ...
                            );
        pop_ccm = uicontrol(comPropAll{:},          ...
                            'Style','Popup',        ...
                            'Position',pos_pop_ccm, ...
                            'String',str_pop_ccm,   ...
                            'Value',1,              ...
                            'UserData',0,           ...
                            'Enable','Off',         ...
                            'Callback',cba_pop_ccm  ...
                            );
        %-----------------------------------------------------------------%

        % Callbacks update.
        %------------------
        utanapar('set_cba_num',win_tool,[m_files;pus_ana]);
        drawnow;

        %  Normalization.
        %----------------
        Pos_Graphic_Area = wfigmngr('normalize',win_tool,Pos_Graphic_Area);

        % Tool Parameters & Axes Construction.
        %-------------------------------------     
        [hdl_Re_AXES,hdl_Im_AXES] = cw1dutil('initPosAxes',win_tool,'all',...
                                         Pos_Graphic_Area);

		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------
		hdl_CW_SCALES = [ ...
			fra_sca,txt_sca,pop_sca, ...
			txt_min,edi_min,txt_stp,edi_stp, ...
			txt_max,edi_max,txt_pow,pop_pow, ...
			txt_msc,edi_msc                  ...
			];
		hdl_CW_COEFLINE = [pus_lin];
		hdl_CW_MAXLINE  = [pus_ref];
		hdl_CW_SCAL2FRQ = [rad_SCA,rad_FRQ];
		hdl_CW_COLMODE  = [fra_ccm,txt_ccm,pop_ccm];
		wfighelp('add_ContextMenu',win_tool,hdl_CW_SCALES,'CW_SCALES');
		wfighelp('add_ContextMenu',win_tool,hdl_CW_COEFLINE,'CW_COEFLINE');
		wfighelp('add_ContextMenu',win_tool,hdl_CW_MAXLINE,'CW_MAXLINE');
		wfighelp('add_ContextMenu',win_tool,hdl_CW_SCAL2FRQ,'CW_SCAL2FRQ');
		wfighelp('add_ContextMenu',win_tool,hdl_CW_COLMODE,'CW_COLMODE');		
		%-------------------------------------
									 
        % Memory for stored values.
        %--------------------------
        wmemtool('ini',win_tool,n_InfoInit,nb0_stored);
        wmemtool('ini',win_tool,n_param_anal,nb1_stored);
        wmemtool('ini',win_tool,n_coefs_sca,nb2_stored);
        wmemtool('wmb',win_tool,n_param_anal,ind_gra_area,Pos_Graphic_Area);
        wmemtool('wmb',win_tool,n_coefs_sca,ind_sca_OR_frq,ind_scales);

        fields = {...
          'fra_sam','txt_sam','edi_sam', ...
          'fra_sca','txt_sca','pop_sca', ...
          'pus_ana',                     ...
          'txt_min','edi_min',           ...
          'txt_stp','edi_stp',           ...
          'txt_max','edi_max',           ...
          'txt_pow','pop_pow',           ...
          'txt_msc','edi_msc',           ...
          'pus_lin','pus_ref',           ...
          'fra_axe','txt_axe',           ...
          'rad_MOD','rad_ANG','rad_ALL', ...
          'chk_DEC','chk_LC' ,'chk_LML', ...
          'rad_SCA','rad_FRQ',           ...
          'fra_ccm','txt_ccm','pop_ccm'  ...
          };

        values = {...
           fra_sam , txt_sam , edi_sam , ...
           fra_sca , txt_sca , pop_sca , ...
           pus_ana ,                     ...
           txt_min , edi_min ,           ...
           txt_stp , edi_stp ,           ...
           txt_max , edi_max ,           ...
           txt_pow , pop_pow ,           ...
           txt_msc , edi_msc ,           ...
           pus_lin , pus_ref ,           ...
           fra_axe , txt_axe ,           ...
           rad_MOD , rad_ANG , rad_ALL,  ...
           chk_DEC , chk_LC  , chk_LML , ...
           rad_SCA , rad_FRQ ,           ...
           fra_ccm , txt_ccm , pop_ccm   ...
           };
        
        hdl_UIC = cell2struct(values,fields,2);

        hdl_MEN = [men_load ; men_save ; men_demo];
        handles = struct(...
            'hdl_MEN',hdl_MEN, ...
            'hdl_UIC',hdl_UIC, ...
            'hdl_Re_AXES',hdl_Re_AXES,...
            'hdl_Im_AXES',hdl_Im_AXES ...
            );
        wfigmngr('storeValue',win_tool,['CW1D_handles'],handles);

        % End waiting.
        %---------------
        wwaiting('off',win_tool);

    case 'close'

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end
