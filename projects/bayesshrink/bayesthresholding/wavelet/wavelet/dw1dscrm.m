function [out1,out2] = dw1dscrm(option,win_dw1dtool,in3,in4,in5)
%DW1DSCRM Discrete wavelet 1-D show and scroll mode manager.
%   [OUT1,OUT2] = DW1DSCRM(OPTION,WIN_DW1DTOOL,IN3,IN4,IN5)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 27-Jun-2001.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.17 $ $Date: 2002/04/14 19:44:27 $

% MemBloc1 of stored values.
%---------------------------
n_param_anal   = 'DWAn1d_Par_Anal';
ind_sig_name   = 1;
ind_sig_size   = 2;
ind_wav_name   = 3;
ind_lev_anal   = 4;
ind_axe_ref    = 5;
ind_act_option = 6;
ind_ssig_type  = 7;
ind_thr_val    = 8;
nb1_stored     = 8;

% MemBloc2 of stored values.
%---------------------------
n_coefs_longs = 'Coefs_and_Longs';
ind_coefs     = 1;
ind_longs     = 2;
nb2_stored    = 2;

% MemBloc4 of stored values.
%---------------------------
n_miscella     = 'DWAn1d_Miscella';
ind_graph_area =  1;
ind_view_mode  =  2;
ind_savepath   =  3;
nb4_stored     =  3;

% Tag property of objects.
%-------------------------
tag_valapp_scr = 'ValApp_Scr';
tag_txtapp_scr = 'TxtApp_Scr';
tag_valdet_scr = 'ValDet_Scr';
tag_txtdet_scr = 'TxtDet_Scr';

tag_axeappini  = 'Axe_AppIni';
tag_axedetini  = 'Axe_DetIni';
tag_axecfsini  = 'Axe_CfsIni';
tag_axecolmap  = 'Axe_ColMap';
tag_s_inapp    = 'Sig_in_App';
tag_ss_inapp   = 'SSig_in_App';
tag_s_indet    = 'Sig_in_Det';
tag_ss_indet   = 'SSig_in_Det';
tag_app        = 'App';
tag_det        = 'Det';
tag_img_cfs    = 'Img_Cfs';
tag_img_sca    = 'Img_Sca';

children    = get(win_dw1dtool,'Children');
axe_handles = findobj(children,'flat','type','axes');
uic_handles = findobj(children,'flat','type','uicontrol');
txt_handles = findobj(uic_handles,'Style','text');
pop_handles = findobj(uic_handles,'Style','popupmenu');
axe_app_ini = findobj(axe_handles,'flat','Tag',tag_axeappini);
axe_det_ini = findobj(axe_handles,'flat','Tag',tag_axedetini);
axe_cfs_ini = findobj(axe_handles,'flat','Tag',tag_axecfsini);
axe_col_map = findobj(axe_handles,'flat','Tag',tag_axecolmap);

switch option
    case 'app'
        pop = findobj(pop_handles,'Tag',tag_valapp_scr);
        num = get(pop,'Value');
        old = findobj(axe_app_ini,'Tag',tag_app);
        if ~isempty(old)
            hdl_line = findobj(old,'Userdata',num);
            if ~isempty(hdl_line)
                ii = find(old==hdl_line);
                old(ii) = [];
                num = 0;
                try , delete(old); end
                return
            end
        end

        % Begin waiting.
        %---------------
        wwaiting('msg',win_dw1dtool,'Wait ... computing');

        try , delete(old); end
        x = dw1dfile('app',win_dw1dtool,num);
        Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_lev_anal);
        col_app = wtbutils('colors','app',Level_Anal);
        line('Parent',axe_app_ini,'Xdata',[1:length(x)],'Ydata',x,...
             'Color',col_app(num,:),'Tag',tag_app,'Userdata',num);
        str_tit = get(get(axe_app_ini,'title'),'String');
        ind = findstr(str_tit,'level');
        str_tit = [str_tit(1:ind+5) sprintf('%.0f',num)];
        wtitle(str_tit,'Parent',axe_app_ini);

        % End waiting.
        %-------------
        wwaiting('off',win_dw1dtool);

    case 'det'
        pop = findobj(pop_handles,'Tag',tag_valdet_scr);
        num = get(pop,'Value');
        old = findobj(axe_det_ini,'Tag',tag_det);
        if ~isempty(old)
            hdl_line = findobj(old,'Userdata',num);
            if ~isempty(hdl_line)
                ii = find(old==hdl_line);
                old(ii) = [];
                num = 0;
                try , delete(old); end
                return
            end
        end

        % Begin waiting.
        %---------------
        wwaiting('msg',win_dw1dtool,'Wait ... computing');

        try , delete(old); end
        ll = findobj(axe_det_ini,'type','line','Visible','On');
        if isempty(ll)
            [x,set_ylim,ymin,ymax] = dw1dfile('det',win_dw1dtool,num,1);
        else
            set_ylim = 0;
            x = dw1dfile('det',win_dw1dtool,num);
        end
        Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_lev_anal);
        col_det = wtbutils('colors','det',Level_Anal);
        line('Parent',axe_det_ini,'Xdata',[1:length(x)],'Ydata',x,...
             'Color',col_det(num,:),'Tag',tag_det,'Userdata',num);
        if set_ylim , set(axe_det_ini,'Ylim',[ymin,ymax]); end
        str_tit = get(get(axe_det_ini,'title'),'String');
        ind = findstr(str_tit,'level');
        str_tit = [str_tit(1:ind+5) sprintf('%.0f',num)];
        wtitle(str_tit,'Parent',axe_det_ini);

        % End waiting.
        %-------------
        wwaiting('off',win_dw1dtool);

    case 'plot_sig'
        % in3 = signal
        % in4 = display mode
        % in5 = sig  visibility  
        %----------------------
        if     nargin==3 , in4 = 1; in5 = 1;
        elseif nargin==4 , in5 = 1;
        end
        if in4==1 , v = 1; else , v = 0; end
        axe_hdl = dw1dscrm('axes',win_dw1dtool,[1 1 1],1);
        vsig = getonoff(in5);
        set(axe_hdl(1),'Visible',vsig);
        set(axe_hdl(2:4),'Visible',getonoff(v));

        % Drawing.
        %---------
        axeAct = axe_hdl(1);
        wtitle('Loaded Signal','Parent',axeAct);
        col_s = wtbutils('colors','sig');
        line('Parent',axeAct,'Xdata',[1:length(in3)],'Ydata',in3,...
             'Color',col_s,'Visible',vsig,'Tag',tag_s_inapp);

        axeAct = axe_hdl(2);
        xmin = 1;             xmax = length(in3);
        ymin = min(in3)-eps;  ymax = max(in3)+eps;
        line('Parent',axeAct,'Xdata',[xmin:xmax],'Ydata',in3,...
             'Color',col_s,'Visible','Off','Tag',tag_s_indet);
        set(axe_hdl(1:3),'Xlim',[xmin xmax],'Ylim',[ymin ymax]);

    case 'plot_anal'
        lin_handles = findobj(axe_handles,'Type','line');
        ss_in_app   = findobj(lin_handles,'Tag',tag_ss_inapp);
        if isempty(ss_in_app)
            col_ss = wtbutils('colors','ssig');
            ss_rec = dw1dfile('ssig',win_dw1dtool);
            line(...
                 'Parent',axe_app_ini, ...
                 'Xdata',[1:length(ss_rec)],'Ydata',ss_rec, ...
                 'Zdata',2*ones(size(ss_rec)),...
                 'Color',col_ss,'Visible','Off','Tag',tag_ss_inapp);
            line(...
                 'Parent',axe_det_ini, ...
                 'Xdata',[1:length(ss_rec)],'Ydata',ss_rec, ...
                 'Zdata',2*ones(size(ss_rec)), ...
                 'Color',col_ss,'Visible','Off','Tag',tag_ss_indet);

            clear ss_rec
        end

        Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_lev_anal);
        [app_rec,set_ylim,ymin,ymax] = dw1dfile('app',win_dw1dtool,1,1);
        ylim = get(axe_app_ini,'Ylim');
        if ylim(1)<ymin , ymin = ylim(1); end
        if ylim(2)>ymax , ymax = ylim(2); end
        col_app = wtbutils('colors','app',Level_Anal);
        line(...
             'Parent',axe_app_ini,...
             'Xdata',[1:length(app_rec)],'Ydata',app_rec,...
             'Color',col_app(1,:),'Tag',tag_app,'Userdata',1);
        wtitle(sprintf('Signal and Approximation at level %.0f',1),...
                'Parent',axe_app_ini)
        set(axe_app_ini,'Ylim',[ymin,ymax]);
        clear app_rec

        [det_rec,set_ylim,ymin,ymax] = dw1dfile('det',win_dw1dtool,1,1);
        col_det = wtbutils('colors','det',Level_Anal);
        line(...
             'Parent',axe_det_ini,...
             'Xdata',[1:length(det_rec)],'Ydata',det_rec,...
             'Color',col_det(1,:),'Tag',tag_det,'Userdata',1);
        if set_ylim , set(axe_det_ini,'Ylim',[ymin,ymax]); end
        wtitle(sprintf('Detail at level %.0f',1),...
                'Parent',axe_det_ini)
        clear det_rec

        clear longs coefs
        [det_cfs,xlim1,xlim2,ymax,ymin,nb_cla,levs,ccfs_vm] = ...
                                dw1dmisc('col_cfs',win_dw1dtool);
        levlab  = flipud(int2str(levs(:)));
        img_cfs = image(flipud(det_cfs),...
                        'Parent',axe_cfs_ini,         ...
                        'Tag',tag_img_cfs,            ...
                        'Userdata',[ccfs_vm,levs,xlim1,xlim2,nb_cla]);
        set(axe_cfs_ini,'YTicklabelMode','manual',...
                        'YTick',[1:length(levs)], ...
                        'YTickLabel',levlab,      ...
                        'Ylim',[0.5 Level_Anal+0.5], ...
                        'Tag',tag_axecfsini       ...
                        );
        wtitle('Details Coefficients','Parent',axe_cfs_ini);
        wylabel('Level number','Parent',axe_cfs_ini)
        clear dec_cfs

        image([0 1],[0 1],[1:nb_cla],'Parent',axe_col_map,'Tag',tag_img_sca);
        set(axe_col_map,...
                'XTickLabel',[],'YTickLabel',[],...
                'XTick',[],'YTick',[],'Tag',tag_axecolmap);
        wsetxlab(axe_col_map,'Scale of colors from MIN to MAX');

        % Reference axes used by stat. & histo & ...
        %-------------------------------------------
        wmemtool('wmb',win_dw1dtool,n_param_anal,ind_axe_ref,axe_app_ini);

        % Axes attachment.
        %-----------------
        dw1dscrm('dynv',win_dw1dtool);

    case 'plot_cfs'
        % in3 = display mode
        %------------------
        if nargin==2 , in3 = 1; end
        if in3==1 , v = 1; else , v = 0; end
        v = 0;  % force l'affichage des coefficients

        axe_hdl = dw1dscrm('axes',win_dw1dtool,[1 v 1],1);
        set(axe_hdl(2),'Visible',getonoff(v));
        set(axe_hdl(1,3:4),'Visible','On');

        Signal_Size = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_sig_size);
        xmin = 1;  xmax = Signal_Size;
        ta3 = 'Loaded Details Coefficients (Colored)';
        if v
            set(axe_hdl(1:3),'Xlim',[xmin xmax]);
        else
            [coefs,longs] = wmemtool('rmb',win_dw1dtool,...
                                            n_coefs_longs,ind_coefs,ind_longs);
            coefs = coefs(longs(1)+1:end);
            longs = longs(2:end-1);
            nbd   = length(longs);
            ymin = min(coefs);
            ymax = max(coefs);
            if ymin==ymax , dy = 0.001; else ,dy = (ymax-ymin)/20; end
            ymin = ymin-dy; ymax = ymax+dy;
            axe_act = axe_hdl(1);
            set(axe_act,'Xlim',[1 length(coefs)],'Ylim',[ymin ymax]);
            wtitle(['Loaded Details Coefficients from level '...
                     sprintf('%.0f',nbd) ' to level 1.'],'Parent',axe_act);
            line('Parent',axe_act,'Xdata',[1:length(coefs)],'Ydata',coefs, ...
                 'Color',wtbutils('colors','coefs'));
            x = 0;
            linCOL = wtbutils('colors','dw1d','sepcfs');
            for k = 1:nbd-1
                x = x+longs(k);
                line('Parent',axe_act,'Xdata',[x x],'Ydata',[ymin ymax], ...
                     'Color',linCOL);
            end
            drawnow
            set(axe_hdl(2:3),'Xlim',[xmin xmax]);
        end

        axe_act = axe_hdl(3);
        [det_cfs,xlim1,xlim2,ylim2,ylim1,nb_cla,levs,ccfs_vm] = ...
                                dw1dmisc('col_cfs',win_dw1dtool);
        levlab  = flipud(int2str(levs(:)));
        img_cfs = image(flipud(det_cfs),   ...
                        'Parent',axe_act,  ...
                        'Tag',tag_img_cfs, ...
                        'Userdata',[ccfs_vm,levs,xlim1,xlim2,nb_cla]);
        wtitle(ta3,'Parent',axe_act);
        wylabel('Level number','Parent',axe_act)
        set(axe_act,'YTicklabelMode','manual',   ...
                    'YTick',[1:length(levs)],    ...
                    'YTickLabel',levlab,         ...
                    'Ylim',[0.5 length(levs)+0.5],...
                    'Tag',tag_axecfsini          ...
                    );

        axe_act = axe_hdl(4);
        image([0 1],[0 1],[1:nb_cla],'Parent',axe_act,'Tag',tag_img_sca);
        set(axe_act,...
                'XTickLabel',[],'YTickLabel',[],...
                'XTick',[],'YTick',[],'Tag',tag_axecolmap);
        wsetxlab(axe_act,'Scale of colors from MIN to MAX');

        if v==0
            set(axe_hdl(1),'Xlim',[1 length(coefs)],'Ylim',[ymin ymax]);
        end

    case 'plot_synt'
        % Getting  Synthesis parameters.
        %------------------------------
        Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_lev_anal);

        % Computing Decomposition.
        %-------------------------
        col_s   = wtbutils('colors','sig');
        col_ss  = wtbutils('colors','ssig');
        col_app = wtbutils('colors','app',Level_Anal);
        col_det = wtbutils('colors','det',Level_Anal);

        delete(get(axe_app_ini,'Children'));
        axe_hdl = dw1dscrm('axes',win_dw1dtool,[1 1 1],0);
        set(axe_hdl,'Visible','On');

        sig_rec = dw1dfile('sig',win_dw1dtool);
        line(...
             'Parent',axe_app_ini,...
             'Xdata',[1:length(sig_rec)],'Ydata',sig_rec,...
             'Color',col_s,'Tag',tag_s_inapp);
        line(...
             'Parent',axe_app_ini,...
             'Xdata',[1:length(sig_rec)],'Ydata',sig_rec, ...
             'Zdata',2*ones(size(sig_rec)),...
             'Color',col_ss,'Visible','Off','Tag',tag_ss_inapp);

        app_rec = dw1dfile('app',win_dw1dtool,1);
        line(...
             'Parent',axe_app_ini,...
             'Xdata',[1:length(app_rec)],'Ydata',app_rec,...
             'Color',col_app(1,:),'Tag',tag_app,'Userdata',1);
        wtitle(sprintf('Original Synthesized Signal and Approximation at level %.0f',1),...
		       'Parent',axe_app_ini)
        clear app_rec
        [det_rec,set_ylim,ymin,ymax] = dw1dfile('det',win_dw1dtool,1,1);
        line(...
             'Parent',axe_det_ini,...
             'Xdata',[1:length(sig_rec)],'Ydata',sig_rec,...
             'Color',col_s,'Visible','Off','Tag',tag_s_indet);
        line(...
             'Parent',axe_det_ini,...
             'Xdata',[1:length(sig_rec)],'Ydata',sig_rec,...
             'Zdata',2*ones(size(sig_rec)),...
             'Color',col_ss,'Visible','Off','Tag',tag_ss_indet);

        line(...
             'Parent',axe_det_ini,...
             'Xdata',[1:length(det_rec)],'Ydata',det_rec,...
             'Color',col_det(1,:),'Tag',tag_det,'Userdata',1);
        if set_ylim , set(axe_det_ini,'Ylim',[ymin ymax]); end
        wtitle(sprintf('Detail at level %.0f',1),'Parent',axe_det_ini)

        wtitle('Details Coefficients','Parent',axe_cfs_ini);
        wylabel('Level number','Parent',axe_cfs_ini);

        wsetxlab(axe_col_map,'Scale of colors from MIN to MAX');

        % Reference axes used by stat. & histo & ...
        %-------------------------------------------
        wmemtool('wmb',win_dw1dtool,n_param_anal,ind_axe_ref,axe_app_ini);

        % Axes attachment.
        %-----------------
        dw1dscrm('dynv',win_dw1dtool);

    case 'view'
        % in3 = old_mode
        %----------------
        % in3 = -1 : same mode
        % in3 =  0 : clean
        % in3 =  1 : scr mode
        % in3 =  2 : dec mode
        % in3 =  3 : sep mode
        % in3 =  4 : sup mode
        % in3 =  5 : tre mode
        % in3 =  6 : cfs mode
        %---------------------------
        old_mode = in3;
        [flg_axe,flg_sa,flg_app,flg_sd,flg_det,ccfs_m] = ...
                                dw1dvmod('get_vm',win_dw1dtool,1);
        v_flg = [flg_sa , flg_app , flg_sd , flg_det , flg_axe(3)];
        if flg_axe(1)== 0 , v_flg(1:3) = zeros(1,3); end
        if flg_axe(2)== 0 , v_flg(4:6) = zeros(1,3); end
        if flg_axe(3)== 0 , v_flg(7)   = 0; end

        pop_app  = findobj(pop_handles,'Tag',tag_valapp_scr);
        lev_a    = get(pop_app,'Value');
        pop_det  = findobj(pop_handles,'Tag',tag_valdet_scr);
        lev_d    = get(pop_det,'Value');

        vis_str  = getonoff(v_flg);
        v_s_app  = vis_str(1,:);
        v_ss_app = vis_str(2,:);
        v_app    = vis_str(3,:);
        v_s_det  = vis_str(4,:);
        v_ss_det = vis_str(5,:);
        v_det    = vis_str(6,:);
        v_cfs    = vis_str(7,:);

        axe_hdl     = dw1dscrm('axes',win_dw1dtool,flg_axe);
        lin_handles = findobj(axe_hdl,'Type','line');
        img_handles = findobj(axe_hdl,'Type','image');
        s_in_app    = findobj(lin_handles,'Tag',tag_s_inapp);
        s_in_det    = findobj(lin_handles,'Tag',tag_s_indet);
        app         = findobj(lin_handles,'Tag',tag_app,'Userdata',lev_a);
        ss_in_app   = findobj(lin_handles,'Tag',tag_ss_inapp);
        ss_in_det   = findobj(lin_handles,'Tag',tag_ss_indet);
        det         = findobj(lin_handles,'Tag',tag_det,'Userdata',lev_d);
        img_cfs     = findobj(img_handles,'Tag',tag_img_cfs);
        img_sca     = findobj(img_handles,'Tag',tag_img_sca);

        [Wave_Name,opt_act,Level_Anal,ss_type] = ...
                wmemtool('rmb',win_dw1dtool,n_param_anal,...
                          ind_wav_name,ind_act_option,ind_lev_anal,...
                                                      ind_ssig_type);
        if     ss_type=='ss', str_ss = 'Synthesized Signal';
        elseif ss_type=='ds', str_ss = 'De-noised Signal';
        elseif ss_type=='cs', str_ss = 'Compressed Signal';
        end

        if strcmp(opt_act,'synt')
            ini_str = 'Orig. Synt. Sig.';
        else
            ini_str = 'Signal';
        end
        if v_flg(1)==1
            if v_flg(2)==1
                str_tit = [ini_str ', ' str_ss ' and']; 
            else    
                str_tit = [ini_str ' and'];     
            end
        else
            if v_flg(2)==1
                str_tit = [str_ss ' and'];      
            else    
                str_tit = '';   
            end
        end
        wtitle([ str_tit ' Approximation at level ' sprintf('%.0f',lev_a)],...
                'Parent',axe_hdl(1));

        if v_flg(4)==1
            if v_flg(5)==1
                str_tit = [ini_str ', ' str_ss ' and']; 
            else    
                str_tit = [ini_str ' and'];     
            end
        else
            if v_flg(5)==1
                str_tit = [str_ss ' and'];      
            else    
                str_tit = '';   
            end
        end
        wtitle([ str_tit ' Detail at level ' sprintf('%.0f',lev_d)],...
                'Parent',axe_hdl(2));

        if isempty(s_in_app)
            x = dw1dfile('sig',win_dw1dtool);
            xmin = 1;           xmax = length(x);
            ymin = min(x)-eps;  ymax = max(x)+eps;
            set(axe_hdl(1:3),'Xlim',[xmin xmax]);
            col_s = wtbutils('colors','sig');
            line(...
                 'Parent',axe_hdl(1),...
                 'Xdata',[xmin:xmax],'Ydata',x,...
                 'Color',col_s,'Visible',v_s_app,'Tag',tag_s_inapp);
            line(...
                 'Parent',axe_hdl(2),...
                 'Xdata',[xmin:xmax],'Ydata',x,...
                 'Color',col_s,'Visible',v_s_det,'Tag',tag_s_indet);
        else
            set(s_in_app,'Visible',v_s_app);
            set(s_in_det,'Visible',v_s_det);
        end
        if isempty(ss_in_app)
            x = dw1dfile('ssig',win_dw1dtool);
            col_ss = wtbutils('colors','ssig');
            line(...
                 'Parent',axe_hdl(1),...
                 'Xdata',[1:length(x)],'Ydata',x,'Zdata',2*ones(size(x)),...
                 'Color',col_ss,'Visible',v_ss_app,'Tag',tag_ss_inapp);
            line(...
                 'Parent',axe_hdl(2),...
                 'Xdata',[1:length(x)],'Ydata',x,'Zdata',2*ones(size(x)),...
                 'Color',col_ss,'Visible',v_ss_det,'Tag',tag_ss_indet);
        else
            set(ss_in_app,'Visible',v_ss_app);
            set(ss_in_det,'Visible',v_ss_det);
        end
        if isempty(app)
            x = dw1dfile('app',win_dw1dtool,lev_a);
            col_app = wtbutils('colors','app',Level_Anal);
            line(...
                 'Parent',axe_hdl(1),...
                 'Xdata',[1:length(x)],'Ydata',x,...
                 'Color',col_app(lev_a,:),'Visible',v_app, ...
                 'Tag',tag_app,'Userdata',lev_a);
        else
            set(app,'Visible',v_app);
        end

        if isempty(det)
            ll = findobj([s_in_det,ss_in_det], 'Visible','on');
            if isempty(ll)
                [x,set_ylim,ymin,ymax] = dw1dfile('det',win_dw1dtool,lev_d,1);
            else
                set_ylim = 0;
                x = dw1dfile('det',win_dw1dtool,lev_d);
            end
            col_det = wtbutils('colors','det',Level_Anal);
            line(...
                 'Parent',axe_hdl(2),...
                 'Xdata',[1:length(x)],'Ydata',x,...
                 'Color',col_det(lev_d,:),'Visible',v_det, ...
                 'Tag',tag_det,'Userdata',lev_d);
            if set_ylim , set(axe_hdl(2),'Ylim',[ymin,ymax]); end
        else
            set(det,'Visible',v_det);
        end

        axe_act = axe_hdl(3);
        [rep,ccfs_vm,levs,xlim,nb_cla] = ...                            
        dw1dmisc('tst_vm',win_dw1dtool,1,axe_act,[1:Level_Anal]);
        if rep==1 ,  delete(img_cfs); img_cfs = []; end
        if isempty(img_cfs)
            [x,xlim1,xlim2,ymax,ymin,nb_cla,levs,ccfs_vm] = ...
                    dw1dmisc('col_cfs',win_dw1dtool,ccfs_vm,levs,xlim,nb_cla);
            levlab  = flipud(int2str(levs(:)));
            img_cfs = image(flipud(x),...
                            'Parent',axe_act,  ...
                            'Visible',v_cfs,   ...
                            'Tag',tag_img_cfs, ...
                            'Userdata',[ccfs_vm,levs,xlim1,xlim2,nb_cla]);
            xlim = get(axe_hdl(1),'Xlim');
            set(axe_act, ...
                       'Xlim',xlim,              ...
                       'YTicklabelMode','manual',...
                       'YTick',[1:length(levs)], ...
                       'YTickLabel',levlab,      ...
                       'Ylim',[0.5 Level_Anal+0.5], ...
                       'Tag',tag_axecfsini       ...
                       );
            clear x
            axe_act = axe_hdl(4);
            image([0 1],[0 1],[1:nb_cla],...
                  'Parent',axe_act,...
                  'Visible',v_cfs,...
                  'Tag',tag_img_sca);
            set(axe_act,...
                    'XTickLabel',[],'YTickLabel',[],...
                    'XTick',[],'YTick',[],'Tag',tag_axecolmap);
        else
            set([img_cfs img_sca],'Visible',v_cfs);
        end
        set(axe_hdl(3:4),'Visible',v_cfs);

        axe_act = axe_hdl(3);
        wylabel('Level number','Parent',axe_act);
        wtitle('Details Coefficients','Parent',axe_act);
        if strcmp(deblankl(v_cfs),'on') 
            drawnow
            wsetxlab(axe_hdl(4),'Scale of colors from MIN to MAX');
        end

        % Axes attachment.
        %-----------------
        dw1dscrm('dynv',win_dw1dtool,old_mode);

        % Reference axes used by stat. & histo & ...
        %-------------------------------------------
        wmemtool('wmb',win_dw1dtool,n_param_anal,ind_axe_ref,axe_hdl(1));

    case 'dynv'
        % in3 = old_mode or ...
        % in3 = -1 : same mode
        % in3 =  0 : clean 
        %-----------------------

        % Axes attachment.
        %-----------------
        if nargin==2 , in3 = 0; end
        okNew = dw1dvdrv('test_mode',win_dw1dtool,'scr',in3);
        if okNew
            Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,...
                                            ind_lev_anal);
            dynvtool('get',win_dw1dtool,0,'force');
            dynvtool('init',win_dw1dtool,...
                    [],[axe_app_ini axe_det_ini,axe_cfs_ini],[],[1 0], ...
                    '','','dw1dcoor',[win_dw1dtool,axe_cfs_ini,Level_Anal]);
        end

    case 'axes'
        % in3 flag for axes visibility
        % in4 flag for clearing axes
        % in4 = 1 , clear axes.
        %---------------------------
        switch nargin
          case 2 , flg_axe = [1 1 1]; clear_axes = 1;
          case 3 , flg_axe = in3;     clear_axes = 0;
          case 4 , flg_axe = in3;     clear_axes = in4;
        end

        % Axes Positions.
        %----------------
        nb_axes = sum(flg_axe);
        pos_graph = wmemtool('rmb',win_dw1dtool,n_miscella,ind_graph_area);
        pos_win = get(win_dw1dtool,'Position');
        bdx  = 0.06*pos_win(3);
        bdy  = 0.08*pos_win(4);
        bdy0 = 0.04*pos_win(4);
        bdy1 = 0.04*pos_win(4);
        bdy2 = 0.06*pos_win(4);
        %--------------------- Scale of Colors Axes ----------------------%
        h_col  = 0.02*pos_win(4);
        w_col  = pos_graph(3)/3;
        x_col  = pos_graph(1)+w_col;
        y_col  = pos_graph(2)+bdy0;
        pos_ax = zeros(4,4);
        pos_ax(4,:) = [x_col , y_col , w_col , h_col];
        %-----------------------------------------------------------------%
        if nb_axes==0 , nb_axes = 3 ;end
        xleft = pos_graph(1)+bdx;
        width = pos_graph(3)-2*bdx;
        hy = pos_graph(4)-(nb_axes-1)*bdy-bdy0-bdy2;
        if flg_axe(3)==1
            ylow        = y_col+h_col+bdy1;
            height      = (hy-bdy1-h_col)/nb_axes;
            pos_ax(3,:) = [xleft , ylow , width , height];
            ylow = ylow+height+bdy;

        else
            ylow = pos_graph(2)+bdy0;
            height = hy/nb_axes;
        end
        if flg_axe(2)==1
            pos_ax(2,:) = [xleft , ylow , width , height];
            ylow = ylow+height+bdy;
        end

        if flg_axe(1)==1
            pos_ax(1,:) = [xleft , ylow , width , height];      
        end
        axe_hdl = findobj(axe_handles,'flat','Tag',tag_axeappini);
        if ~isempty(axe_hdl)
            out1(1) = axe_hdl;
            out1(2) = findobj(axe_handles,'flat','Tag',tag_axedetini);
            out1(3) = findobj(axe_handles,'flat','Tag',tag_axecfsini);
            out1(4) = findobj(axe_handles,'flat','Tag',tag_axecolmap);
            if clear_axes , cleanaxe(out1) ; end             
        else
            win_units = get(win_dw1dtool,'Units');
            axeProp = {...
               'Parent',win_dw1dtool, ...
               'Units',win_units,     ...
               'Visible','Off',       ...
               'DrawMode','Normal',   ...
               'box','on'             ...
               };            
            out1(1) = axes(axeProp{:},...
                           'NextPlot','Add',   ...
                           'Tag',tag_axeappini ...
                           );
            out1(2) = axes(axeProp{:},...
                           'NextPlot','Add',   ...
                           'Tag',tag_axedetini ...
                           );
            out1(3) = axes(axeProp{:},...
                           'NextPlot','Replace',...
                           'Tag',tag_axecfsini  ...
                           );
            out1(4) = axes(axeProp{:},...
                            'XTicklabelMode','manual',...
                            'YTicklabelMode','manual',...
                            'XTickLabel',[],        ...
                            'YTickLabel',[],        ...
                            'XTick',[],'YTick',[],  ...
                            'NextPlot','Replace',   ...
                            'Tag',tag_axecolmap     ...
                            );
            ud.dynvzaxe.enable = 'off';							
			setappdata(out1(4),'WTBX_UserData',ud);				
        end
        flg_vis = [flg_axe flg_axe(3)];
        for k =1:4
            if flg_vis(k)==0
                h = findobj(out1(k));
                set(h,'Visible','off');
            else
                set(out1(k),'Visible','on','Position',pos_ax(k,:));
            end
        end

    case 'del_ss'
        lin_handles = findobj(axe_handles,'Type','line');
        ss_app = findobj(lin_handles,'Tag',tag_ss_inapp);
        ss_det = findobj(lin_handles,'Tag',tag_ss_indet);
        delete([ss_app ss_det]);

    case 'clear'
        % in3 = 0 : clean 
        %------------------
        new_mode = in3;
        okNew = dw1dvdrv('test_mode',win_dw1dtool,'scr',new_mode);
        if okNew , dynvtool('stop',win_dw1dtool); end
        set(findobj([axe_app_ini,axe_det_ini,axe_cfs_ini,axe_col_map]),...
                'visible','off');
        if okNew==1
            cleanaxe([axe_app_ini,axe_det_ini,axe_cfs_ini,axe_col_map]);
            drawnow;
        elseif okNew==2     % superimpose mode
            old_app = findobj(axe_app_ini,'Tag',tag_app);
            old_det = findobj(axe_det_ini,'Tag',tag_det);
            delete([old_app;old_det]);
        end

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end
        
