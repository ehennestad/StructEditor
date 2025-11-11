feedback = struct();
feedback.Rating = [];
feedback.Rating_ = @Rating;
feedback.Feedback = '';
feedback.Feedback_ = @uitextarea;

completedFeedback = uiform(feedback, ...
    "Title", "Feedback", ...
    "Description", "Please leave a rating and provide feedback", ...
    "Height", 300);

