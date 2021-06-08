import "flatpickr/dist/flatpickr.min.css";

import flatpickr from 'flatpickr';

function initFlatpickr() {
    flatpickr("#datetime-picker", {
        enableTime: true,
        altInput: true,
        altFormat: "F j, Y, h:i K",
        dateFormat: "Z",
        defaultDate: existingDate ? Date.parse(existingDate) : new Date().setMinutes(0),
        onChange: (selectedDates, dateStr, instance) => {
            this.showPastAlert = Date.parse(dateStr) < new Date();
        }
    });
}

window.datetimePicker = function() {
    return {
        showPastAlert: false,
        initFlatpickr
    }
}
