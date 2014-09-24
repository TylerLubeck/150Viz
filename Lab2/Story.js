Number.prototype.map = function ( in_min , in_max , out_min , out_max ) {
      return ( this - in_min ) * ( out_max - out_min ) / ( in_max - in_min ) + out_min;
}

Drawing = {};
var Drawing = function() {
    var result;
    this.closedPotholes = {};  
    this.allPotholes = {}; 
    this.openPotholes = {}; 
    var intColor = 0;
    this.mode = 0;
    var _this = this;

    this.nextMode = function() {
        this.mode++;
        if (this.mode > 2) {
            this.mode = 0;
        }
    }

    this.prevMode = function() {
        this.mode--;
        if (this.mode < 0) {
            this.mode = 2;
        }
    }

    function countFrequency(result) {
        var count = {}; 
        for (var i = 0; i < result.length; i++) {
            if (! Boolean(result[i].zip)) {
                continue;
            }
            if (Boolean(count[result[i].zip])) {
                count[result[i].zip]++;
            } else {
                count[result[i].zip] = 1; 
            }
        }
        //TODO: I think if you can turn this dictionary in to a list of the form
        //      [{02155: 20}, {02156: 10}, ...] 
        //      then we'll be in pretty good shape.
        var keys = Object.keys(count);
        keys.sort();
        objects = [];
        for (var k in keys) {
            obj = {}
            obj[keys[k]] = count[keys[k]];
            objects.push(obj);
        }
        //return count; 
        return objects;
    }

    this.init = function() {
        d3.csv("open_potholes.csv", function (d) {
            return {
                zip : d.LOCATION_ZIPCODE
            }; 
        }, function(err, d) {
            if(err) {
                return console.log('Oops! csv died.');
            }
            _this.openPotholes = countFrequency(d); 
            console.log(_this.openPotholes);
            console.log("GOT OPEN: " + _this.openPotholes);  

            d3.csv("closed_potholes.csv", function (d) {
                return {
                    zip : d.LOCATION_ZIPCODE
                }; 
            }, function(err, d) {
                if(err) {
                    return console.log('Oops! csv died.');
                }
                _this.closedPotholes = countFrequency(d); 
                console.log(_this.closedPotholes);  

                d3.csv("pothole_callins.csv", function(d){
                    return {
                        zip : d.LOCATION_ZIPCODE 
                      };		
                }, function(err, d){
                    if(err) {
                        return console.log('Oops! csv died.');
                    }
                    _this.allPotholes = countFrequency(d);
                    console.log(_this.allPotholes); 
                    _this.run();
                });

            }); 
        }); 
    }
    
    function sketchProc(p) {	
        var margin = 30, iWidth = 700, iHeight = 400;
        var x1 = margin, x2 = iWidth;
        function drawLines() {
            p.line(x1, iHeight+margin, x2, iHeight+margin);
            p.line(x1, iHeight+margin, x1, margin);
        }

        function step0(objects, width, offset) {
            var leftMost = x1 + 10;
            for (item in objects) {
                for (k in objects[item]) {
                    var val = objects[item][k];
                    if(leftMost + offset < p.mouseX &&
                       p.mouseX < leftMost+offset+width) {
                        p.fill(p.color(255, 0, 0));
                        $('#display').text(k + " has " + val + " potholes");
                    } else {
                    }
                    val = val.map(0, 2221, 0, iHeight-margin);
                    p.rect(leftMost+offset, iHeight+margin, width, -val);
                    leftMost += 20;
                    p.fill(p.color(0));
                }
            }
        }
       
        p.setup = function(){ 
            p.size(iWidth + 2 * margin, iHeight + 2 * margin, p.P2D);
            $("#canvas1").css("width","" + p.width);
            $("#canvas1").css("height","" + p.height);
            p.smooth();   	 
            p.rectMode(p.CORNER);
            p.ellipseMode(p.RADIUS);
            console.log(p)
        };
       
        p.draw = function() {
            p.background(p.color(250));
            p.stroke(p.color(0));
            p.fill(p.color(0));
            drawLines();
            switch (_this.mode) {
                case 0:
                    $('#subtitle').text("Open Potholes");
                    step0(_this.openPotholes, 10, 0);
                    break; 
               case 1:
                    $('#subtitle').text("Closed Potholes");
                   //step1();
                    step0(_this.closedPotholes, 10, 0);
                   break;
               case 2:
                    $('#subtitle').text("Combined Potholes");
                    step0(_this.closedPotholes, 5, 5);
                    p.fill(p.color(255, 0, 0));
                    step0(_this.openPotholes, 5, 0);
                   break;
           }
        };
    }

    this.run = function(result) {
        var canvas = document.getElementById("canvas1");
        var processingInstance = new Processing(canvas, sketchProc); 
    }
}

	 

$(function() {
    drawing = new Drawing();
    drawing.init();
    $('#pre').attr('disabled', true);
    
    $('#next').click(function(e) {
        drawing.nextMode();
        if (drawing.mode >= 2) {
            $('#next').attr('disabled', true);
        }
        if (drawing.mode > 0) {
            $('#pre').attr('disabled', false);
        }
    });
    $('#pre').click(function(e) {
        drawing.prevMode();
        if (drawing.mode === 0) {
            $('#pre').attr('disabled', true);
        }
        if (drawing.mode < 2) {
            $('#next').attr('disabled', false);
        }
    });

});

