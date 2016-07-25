%function StormSurgeViz_Init

PWD=pwd;

HOME=fileparts(which(mfilename));
addpath([HOME '/extern'])

% need to set up main java path before setting any global variables
if isempty(which('ncgeodataset')) || isempty(javaclasspath('-dynamic'))
    cd([HOME '/extern/nctoolbox'])
    setup_nctoolbox;
    fprintf('SSViz++ %s\n','NCTOOLBOX added to Matlab path')
    cd(HOME)
end

if isempty(which('detbndy'))
    cd([HOME '/util'])
    ssinit
end

cd(PWD)

global SSVizOpts
% 
% ThreddsList={
%              'http://opendap.renci.org:1935/thredds'
%              'http://coastalmodeldev.data.noaa.gov/thredds'
% %             'http://mrtee.europa.renci.org:8080/thredds'
%             };
% %            'http://workhorse.europa.renci.org:8080/thredds'
% %            'http://thredds.crc.nd.edu/thredds'
%         
CatalogEntryPoint={
                   'ASGS'
                   'ASGS'
%                   'SSV'
                  };

              
Providers.Tag={'NYHOPS',...
               'RenciAsgs-Daily',...
               'NOAA_ESTOFS',...
               'IrishSeaROMS',...
               'NOAA_Psurge',...
               'RenciAsgs-Tropical',...
               'NOAA_CSDL-Tropical',...
               'COOPS-CBOFS (Test)',...
               'COOPS-TBOFS (Test)',...
               'COOPS-CREOFS (Test)',...
               'COOPS-NWGOFS (Test)',...
               'TACC (Test)'...
               'URI (Test)'...
               };
           
Providers.ThreddsServer{1}='http://mrtee.europa.renci.org:8080/thredds/dodsC/SSV-Ncml/';
Providers.ThreddsServer{2}='http://opendap.renci.org:1935/thredds/dodsC/SSV-Ncml/';
Providers.ThreddsServer{3}='http://localhost:8080/thredds/dodsC/SSV-Ncml/';
idx=2;

 Providers.Url={[Providers.ThreddsServer{idx} 'NYHOPS.ncml']
                [Providers.ThreddsServer{idx} 'RenciAsgs_LatestDaily.ncml']
                'http://coastalmodeldev.data.noaa.gov/thredds/dodsC/dailyESTOFS/latest/ssv.ncml'
                [Providers.ThreddsServer{idx} 'IrishSeaROMS.ncml']
                [Providers.ThreddsServer{idx} 'SLOSH_Psurge.ncml']
                [Providers.ThreddsServer{idx} 'RenciAsgs_LatestTropical.ncml']
                [Providers.ThreddsServer{idx} 'CSDL_Tropical.ncml']
                [Providers.ThreddsServer{idx} 'COOPS-CBOFS.ncml']
                [Providers.ThreddsServer{idx} 'COOPS-TBOFS.ncml']
                [Providers.ThreddsServer{idx} 'COOPS-CREOFS.ncml']
                [Providers.ThreddsServer{idx} 'COOPS-NWGOFS.ncml']
                [Providers.ThreddsServer{idx} 'TACC_TEST.ncml']
                [Providers.ThreddsServer{idx} 'DHS-URI.ncml']
                };
            
                            %[Providers.ThreddsServer{idx} 'ESTOFS.ncml']
                            
Providers.Default=11;

%if ~exist('varargin','var')
%    error([mfilename ' cannot be called directly. Call StormSurgeViz instead.'])
%end

set(0,'DefaultUIControlFontName','Courier')
set(0,'DefaultAxesTickDir','out')
set(0,'DefaultFigureRenderer','zbuffer');

LocalDirectory='./';
TempDataLocation=[HOME '/TempData']; 
DateStringFormatInput='yyyy-mm-dd HH:MM:SS';
DateStringFormatOutput='ddd, dd mmm, HH:MM PM';

% name of Java Topology Suite file
jts='jts-1.9.jar';

%% Default PN/PVs
fprintf('SSViz++ Processing Input Parameter/Value Pairs...\n')
opts=StormSurgeVizOptions;
opts=parseargs(opts);

if exist('MyStormSurgeViz_Init.m','file')
    if opts.Verbose
        fprintf('SSViz++ Found MyStormSurgeViz_Init ...\n')
    end
    p=MyStormSurgeViz_Init;
    snames=fieldnames(p);
    svals=struct2cell(p);
    for i=1:size(snames,1)
        opts=parseargs(opts,snames{i},svals{i});
    end
end

%opts=parseargs(opts,'KeepScalarsAndVectorsInSync',true);

% now process varargins, which will override any parameters set in
% MyStormSurge_Init.m
opts=parseargs(opts,varargin{:});
opts.UseNcml=true;
opts.NcmlDefaultFileName='00_dir.ncml';

SSVizOpts=opts;
SSVizOpts.Storm=lower(SSVizOpts.Storm);
SSVizOpts.Providers=Providers;

% cn=1;
% if isempty(SSVizOpts.ThreddsServer)
%     SSVizOpts.ThreddsServer=ThreddsList{cn};
%     SSVizOpts.CatalogEntryPoint=CatalogEntryPoint{cn};
% end

%scc=get(0,'ScreenSize');
%DisplayWidth=scc(3);

SSVizOpts.AppName=blank(fileread('ThisVersion'));
fprintf('SSViz++ %s\n',SSVizOpts.AppName')

SSVizOpts.HOME = HOME;
%cd(SSVizOpts.HOME)

if SSVizOpts.UseStrTree
    f=[SSVizOpts.HOME '/extern/' jts];
    if exist(f,'file')
        javaaddpath(f);
    else
        disp('Can''t add jts file to javaclasspath.   Disabling strtree searching.')
        SSVizOpts.UseStrTree=false;
    end
end

SSVizOpts.HasMapToolBox=false;
if ~isempty(which('almanac'))
    SSVizOpts.HasMapToolBox=true;
    %set(0,'DefaultFigureRenderer','opengl');
end

%SSVizOpts.UseShapeFiles=false;
if isempty(which('shaperead'))
    SSVizOpts.UseShapeFiles=false;
end

if isempty(which('shapewrite'))
    disp('Can''t locate MATLAB''s shapewrite.  Disabling shape file output.')
    SSVizOpts.CanOutputShapeFiles=false;
end

if ~exist(TempDataLocation,'dir')
    mkdir(TempDataLocation)
end

SSVizOpts.DefaultBoundingBox=NaN;
%SSVizOpts.DefaultBoundingBox=[-100 -78 17 33];
switch lower(SSVizOpts.Mode)
    
    case 'local'
        
        fprintf('SSViz++ Mode is Local.\n')
        fprintf('SSViz++ Local Mode not yet fully supported. Best of Luck... \n')
               
    case 'url'
        
        if isempty(SSVizOpts.Url)
            SSVizOpts.Url=Providers.Url{Providers.Default};
            SSVizOpts.Provider=Providers.Tag{Providers.Default};
            fprintf('SSViz++ No URL provided.  Using default of %s...\n',SSVizOpts.Url)
        end
        
        fprintf('SSViz++ Mode is Url.\n')
        fprintf('SSViz++ Url Mode not yet fully supported. Best of Luck... \n')
                
    case 'network'
       
        SSVizOpts.Mode='Network';
        fprintf('SSViz++ Mode is Network.\n')

    otherwise
        error('Mode %s unknown.  Modes are {''Local'',''Url'',''Network''}',SSVizOpts.Mode)

end

if (~isempty(SSVizOpts.BoundingBox) || isnan(SSVizOpts.BoundingBox)),SSVizOpts.DefaultBoundingBox=SSVizOpts.BoundingBox;end

%SetVectorOptions('Stride',100,'ScaleFac',25,'Color','k')
SSVizOpts.VectorOptions.Stride=10;
SSVizOpts.VectorOptions.ScaleFac=25;
SSVizOpts.VectorOptions.Color='k';


%            b     blue          .     point              -     solid
%            g     green         o     circle             :     dotted
%            r     red           x     x-mark             -.    dashdot 
%            c     cyan          +     plus               --    dashed   
%            m     magenta       *     star             (none)  no line
%            y     yellow        s     square
%            k     black         d     diamond
%            w     white         v     triangle (down)
%                                ^     triangle (up)
%                                <     triangle (left)
%                                >     triangle (right)
%                                p     pentagram
%                                h     hexagram
%                           

%%% clean up after initialization
clear jts
global Debug
Debug=SSVizOpts.Debug;



