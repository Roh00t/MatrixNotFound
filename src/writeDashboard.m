function writeDashboard(dashboardDir, dash)
%WRITEDASHBOARD Write the dashboard data file read by dashboard/index.html.
%
%   WRITEDASHBOARD(dashboardDir, dash) serialises the struct dash to
%   dashboardDir/data.js as "window.DASHBOARD = {...};". The dashboard page
%   loads it with a plain <script> tag, so it works straight from disk
%   (file://) or GitHub Pages with no web server.
%
%   main.m calls this at every stage of the run. While dash.status is
%   "running" the page reloads itself every few seconds, so anyone watching
%   sees each model's score appear as soon as its cross-validation finishes.
%
%   The file is written to a temporary name and then moved into place, so
%   the page never reads a half-written file.

    arguments
        dashboardDir (1,1) string
        dash         (1,1) struct
    end

    if ~isfolder(dashboardDir)
        mkdir(dashboardDir);
    end

    dash.updated = string(datetime("now", Format="yyyy-MM-dd HH:mm:ss"));
    json = jsonencode(dash, PrettyPrint=true);

    target    = fullfile(dashboardDir, "data.js");
    temporary = target + ".tmp";
    fid = fopen(temporary, "w", "n", "UTF-8");
    assert(fid > 0, "writeDashboard:openFailed", "Cannot write %s.", temporary);
    cleanup = onCleanup(@() fclose(fid));
    fprintf(fid, "window.DASHBOARD = %s;\n", json);
    clear cleanup                     % closes the file before the move
    movefile(temporary, target, "f");
end
