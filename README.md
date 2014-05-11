# McGill Utilities

## Description

Crawl McGill's website and the Visual Schedule Builder to determine which courses are being offered and information (professor, timing, capacity) for each section/

## Installation

    $ sudo gem install mcgill-utils

## Usage

So far, the gem only encapsulates the Visual Schedule Builder API in order to provide a list of sections available for each course, along with the professor and timing, etc, of each section.

You need to provide the semester and a list of courses you're interested in. The semester is formated YYYYMM, where the month is either 05 for Summer, 09 for Fall, or 01 for Winter. Courses are formatted `CODE-###`, e.g., `MGCR-293`. Multiple courses can be given at once, either as multiple parameters or as an array.

    > courses = McGill::VSB.new 201409, 'MGCR-293', 'FINE-441', 'COMP-202'

or

    > courses = McGill::VSB.new 201409, ['MGCR-293', 'FINE-449', 'COMP-202']

To get information about each courses section, call `#sections`

    > courses.sections
    => {"FINE-449"=>
       [{:crn=>"8270",
         :kind=>"Lec",
         :waitlist=>false,
         :teacher=>"di Pietro, Vadim",
         :times=>["Thursday 6:05 PM - 8:55 PM, Sep 2 to Dec 3"],
         :notes=>"Enrolment limited by program \nJoint BCom/MBA course."}],
         #...
    }

To check whether it's possible to register for any of the sections, call `#availability`. You'll get back a hash with the crn of the section as the key. If the section has a waitlist, then a result of `true` means that there is space for you to join the waitlist. If there's no waitlist, then `true` means you can join the section immediately. A result of `false` always means that the section, and waitlist if applicable, are full.

    > courses.availability
    => {"BUSA-465"=>{10097=>true}, "COMP-202"=>{823=>true, 824=>false, 825=>false}}

## License

This software is licensed under the MIT license.

Copyright (c) 2014 Noah Lackstein

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.