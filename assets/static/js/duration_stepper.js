const STEP = 15
const MIN = 15
const MAX = 360

window.numberInputComponent = function(defaultMinutes) {
    return {
        minutes: defaultMinutes,
        increment() {
            this.minutes = parseInt(this.minutes) || MIN - MIN;
            this.minutes += STEP;
            if (this.minutes > MAX) this.minutes = MAX;
         },
         decrement() {
            this.minutes = parseInt(this.minutes) || MIN + MIN;
            this.minutes -= STEP;
            if (this.minutes < MIN) this.minutes = MIN;
         }
    }
}
