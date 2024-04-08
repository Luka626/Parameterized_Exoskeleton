function [] = log_to_output(app, log_message)
    log = sprintf("%s", log_message);
    app.TextArea.Value = [app.TextArea.Value; log];
    fprintf(app.fileID, log_message);
    fprintf(app.fileID, "\n");
end
