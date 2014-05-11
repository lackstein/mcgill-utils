module McGill
  class VSB
    DAYS = {
      '1' => 'Sunday',
      '2' => 'Monday',
      '3' => 'Tuesday',
      '4' => 'Wednesday',
      '5' => 'Thursday',
      '6' => 'Friday',
      '7' => 'Saturday'
    }
    
    # Session is the date formated as YYYYMM that the semester starts, eg 201309
    # Courses is an array of courses formated like, eg, ['MCGR-293', 'COMP-202']
    def initialize(session, *courses)
      @session, @courses = session, courses
      
      # We expect a 1-dimensional array of courses, but for convenience we also
      # accept a list of courses as strings with the splat. In this case, we
      # need to flatten the array
      @courses = @courses.flatten
      
      # Not much we can do if we aren't given any courses to look up
      # Raise an exception and let the caller know they're doing it wrong
      raise ArgumentError, "At least one course must be given" if @courses.empty?
      
      # Visual Schedule Builder expects all the course codes to be uppercase
      @courses.map!(&:upcase)
      
      @results = Nokogiri::XML(open(build_url))
    end
  
    # Returns a hash, the keys are the course codes, the values an array of sections
    # {"FINE-449"=>
    #   [{:crn=>"8270",
    #     :kind=>"Lec",
    #     :waitlist=>false,
    #     :teacher=>"di Pietro, Vadim",
    #     :times=>["Thursday 6:05 PM - 8:55 PM, Sep 2 to Dec 3"],
    #     :notes=>"Enrolment limited by program \nJoint BCom/MBA course."}]
    # }
    def sections
      @courses.inject({}) do |course_list, course|
        section_list = @results.xpath("//selection[contains(@key, '#{course}')]").inject([]) do |list, section|
          section.xpath('block').each do |block|
            # If there are no scheduled courses, give a blank array
            timeblocks = block['timeblockids'].split(',') rescue []
            times_list = timeblocks.inject([]) do |times, timeblock_id|
              timeblock = @results.at_xpath("//timeblock[@id=#{timeblock_id}]")
        
              start_time = format_time(timeblock['t1'])
              end_time = format_time(timeblock['t2'])
        
              times.push "#{DAYS[timeblock['day']]} #{start_time} - #{end_time}, #{timeblock['s']}"
              times
            end
      
            section_info = {
              crn: block['key'],
              kind: block['type'],
              waitlist: block['wc'].to_i > 0,
              teacher: block['teacher'].empty? ? "TBA" : block['teacher'],
              times: times_list.empty? ? [] : times_list,
              notes: block['n'].empty? ? "" : block['n'].gsub("<br/>","\n").strip
            }
      
            list.push section_info
          end
          list
        end
        course_list[course] = section_list.uniq
        course_list
      end
    end
  
    # Checks whether there are seats available, or if not then whether there are open spots on the waitlist
    # Returns a Hash of Courses, each Course is a Hash of CRNs with values true (open) or false (closed)
    # {"BUSA-465"=>{10097=>false}, "COMP-202"=>{823=>false, 824=>false, 825=>false}}
    def availability
      @courses.inject({}) do |course_list, course|
        section_list = @results.xpath("//selection[contains(@key, '#{course}')]").inject({}) do |list, section|
          section.xpath('block').each do |block|
            # seats is either 1 (available) or 0 (full), to_bool checks if it's 1
            # If there are available seats, and wc is 0, then there's no waitlist and you can register
            if section['seats'].to_i == 1 && block['wc'].to_i == 0
              section_open = true
            # If wc > 0 and ws > 0, there's a waitlist, and there's space available on it, so you can register
            elsif block['wc'].to_i > 0 && block['ws'].to_i > 0
              section_open = true
            else
              section_open = false
            end
        
            list[block['key']] = section_open
          end
          list
        end
        course_list[course] = section_list
        course_list
      end
    end
  
    private
    # Builds the URL used by Visual Schedule Builder to get class information
    # The URL for COMP-202 in 201309 would be
    # https://vsb.mcgill.ca/resultset.jsp?session_201309=1&course_0_0=COMP-202&sa_0_0=tm&dropdown_0_0=al&td_0_0_0=201309
    def build_url
      url = "https://vsb.mcgill.ca/resultset.jsp?session_#{@session}=1"
      @courses.each_with_index do |course, index|
        url << "&course_#{index}_0=#{course}&sa_#{index}_0=tm&dropdown_#{index}_0=al&td_#{index}_0_0=#{@session}"
      end

      url
    end
    
    # VSB encodes time as the number of minutes since midnight
    # This function converts it to the more human readable hour:min am/pm
    def format_time(minutes)
      hour = minutes.to_i / 60
      min = "%02d" % (minutes.to_i % 60)
      
      if hour > 12
        hour -= 12
        ampm = 'PM'
      elsif hour == 12
        ampm = 'PM'
      else
        ampm = 'AM'
      end
      
      "#{hour}:#{min} #{ampm}"
    end
  end
end