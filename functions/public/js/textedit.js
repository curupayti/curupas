  $(document).ready( function() { 

    "use strict";     

    let deleteIDs = [];
    
    let lastVisible;
    let firstVisible;          

    let _imageSnapshot = {};        

    window.editDocuments = [];

    window._is_detail_drawer = false;
    window._short;
    window._id_document_collection;

    window.editObjects;  

    window.array_images_selected;
    
    var _clicked = false;

    loadData();

    window.mainActiveTable = 0;
    window.mainTotalMain = 0;
    window.mainSteps = 0;
    window.mainPartial = 0;

    function loadData() {
      db.collection('contents').onSnapshot(snapshot => {
          window.mainTotalMain = snapshot.size;
          window.mainSteps = Math.round(window.mainTotalMain/3) - 1;
          $('.count-visible-main').text(3);
          $('.count-total-main').text(window.mainTotalMain);    
      });  
      
      var first = db.collection("contents").limit(3);

      first.get().then(function (documentSnapshots) {         
          var count = 0;
          documentSnapshots.docs.forEach(doc => {            
              if (count==0) {
                firstVisible = doc;              
              } else if (count==2) {
                lastVisible = doc;
              }            
              renderMain(doc);
              count++;
          });
          window.mainPartial = documentSnapshots.docs.length;
      }); 
    }
    
    $('#js-next-main').on('click', function () {              
      window.mainActiveTable++;     
      if ($(this).closest('.page-item').hasClass('disabled')) {
          return false;
      }   
      $('#main-table tbody').html('');   
      var next = db.collection("contents")
          .startAfter(lastVisible)
          .limit(3);
      next.get().then(function (documentSnapshots) {           
        var count = 0; 
        var length = documentSnapshots.docs.length;
        documentSnapshots.docs.forEach(doc => {   
          if (count==0) {
            firstVisible = doc;              
          } else if (count==2) {
            lastVisible = doc;
          }
          renderMain(doc);   
          count++;           
        });           
        window.mainPartial = (window.mainPartial + length);
        $('.count-visible-main').text(window.mainPartial);        
        if (window.mainSteps == window.mainActiveTable) {
          $('#js-next-main').closest('.page-item').addClass('disabled');
        }
        if (window.mainActiveTable != 0) {
          $('#js-previous-main').closest('.page-item').removeClass('disabled');
        }              
        if (!window._main_row_selected && window.activePanelNum==0) {
          return;
        }    
        if (!window._detail_row_selected && window.activePanelNum==1) {
          return;
        }   
      });   
    });
    
    $("#js-previous-main").on('click', function () {
      window.mainActiveTable--;
      $('#main-table tbody').html('');
      var previous;
      if (window.mainActiveTable == 0) {
        previous = db.collection("contents").limit(3);
        $('#js-next-main').closest('.page-item').addClass('enabled');
      } else  {
        var previous = db.collection("contents")          
          //.orderBy(firebase.firestore.FieldPath.documentId(), "desc")
          .startAt(firstVisible)
          .limit(3);
      }     
      previous.get().then(function (documentSnapshots) {
        documentSnapshots.docs.forEach(doc => {              
          renderMain(doc);
        });
        if (window.mainActiveTable == 0) {
          window.mainPartial = documentSnapshots.docs.length;            
        } 
        $('.count-visible-main').text(window.mainPartial);  
      });
      if (window.mainActiveTable == 0) {
        $('#js-previous-main').closest('.page-item').addClass('disabled');        
      }
    });     

    function renderMain(document) { 

        window.editObjects[document.data().short] = document;      
        
        let _last_update = formatDate(Date(document.data().last_update));        

        document.ref.collection("images").get().then(function(imagesSnapshot) {
            
            _imageSnapshot[document.id] = imagesSnapshot;
        
            let item = `<tr class="clickable-row-main" 
                data-id="${document.id}" 
                data-new="${document.data().new}" 
                data-name="${document.data().name}" 
                data-short="${document.data().short}">                
            <td>
                <span class="custom-checkbox">
                    <input type="checkbox" id="${document.id}" value="${document.id}">
                    <label for="${document.id}"></label>
                </span>
            </td>
            <td>${document.data().amount}</td>                 
            <td>${document.data().name}</td>                              
            <td>${document.data().desc}</td>  
            <td>${_last_update}</td>    
            <td>
                <a href="#" id="${document.id}" class="edit js-edit-main"><i class="material-icons" data-toggle="tooltip" title="Edit">&#xE254;</i>
                </a>
                <a href="#" id="${document.id}" class="delete js-delete-main"><i class="material-icons" data-toggle="tooltip" title="Delete">&#xE872;</i>
                </a>
            </td>                                  
            </tr>`;
            $('#main-table').append(item);            

            let checkbox = $('#main-table tbody input[type="checkbox"]');
            $("#selectAllMain").click(function () {
                if (this.checked) {
                    checkbox.each(function () {
                        console.log(this.id);
                        deleteIDs.push(this.id);
                        this.checked = true;
                    });
                } else {
                    checkbox.each(function () {
                        this.checked = false;
                    });
                }
            });
            checkbox.click(function () {
                if (!this.checked) {
                    $("#selectAllMain").prop("checked", false);
                }
            });
            $("#btn-categorias").click();
        });            
    }

    function openDetailModal(){
      $("#detailModal").show()
    }


    // Edit Main
    $(document).on('click', '.js-edit-main', function () {
      let id = $(this).attr('id');
      $('#edit-employee-form').attr('edit-id', id);      
      $('#messageModal').modal('show');
      $('#message-title').text("Atención");
      $('#message-body').text("No tener permisos para realizar esta operación, consultalo con el administrador del sistema.");     
    });


    // Delete Main
    $(document).on('click', '.js-delete-main', function () {
      let id = $(this).attr('id');
      $('#messageModal').modal('show');
      $('#message-title').text("Atención");
      $('#message-body').text("No tener permisos para realizar esta operación, consultalo con el administrador del sistema.");     
    });   

    // VIEW IMAGES
    $(document).on('click', '.clickable-row-main', function (event) {           
        event.preventDefault();

        let dataid = $(this).data("id");
        let _new = $(this).data("new");
        let _short = $(this).data("short");
        let _name = $(this).data("name");

        if (_short=="drawer") {
          window._is_detail_drawer = true;
        } else {
          window._is_detail_drawer = false;
        }

        window._id_document_collection = dataid;           

        window._detail_name = _name;        
        window._detail_new = _new;    

        var checkboxes = $('#main-table tbody input[type="checkbox"]');

        checkboxes.each(function () {
            this.checked = false;
        });

        $(this).find('input[type="checkbox"]').prop("checked", true);                 
        
        $("#detail-table").find("tr:gt(0)").remove();               
        
        loadEditsList(_new, _short);   
        
        $("#detail-grid").show();

        window._main_row_selected = true;        

        $("#btn-categorias").text(_name);
        
        $("#firepad-container").css("left", 0);
        $("#firepad-container").css("height", 570);
        $("#firepad-container").css("width", "100%");

        $("#firepadform").css("height", 650);
        $("#firepaditem").css("height", 570);               
        
    });

    window.jsonDataDetail = [];
    window.editDocuments = [];
    window._main_row_selected = false;
    window._detail_row_selected = false;
    window._short;
    window._id_document_collection;
    window.detailDocuments;
    window.limitedDetailArray = [];
    window.active_detail;

    window.loadEditsList = function(_new, _short) { 

      window._short = _short;          
      window.detailDocuments = window.editObjects[_short];   

      window.detailDocuments.ref.collection("collection").get()
      .then(function(querySnapshotDetail) {       
        
        let countLimit = 3;
        let limit = 0;
        let counter = 0;        
        var tempArray = new Array;

        querySnapshotDetail.forEach(function(docEdit) {       

          if (limit==countLimit) {
            window.limitedDetailArray[counter] = tempArray;
            tempArray = [];
            limit = 0;
            counter++;
          } else {    
            tempArray[limit] = docEdit;            
            limit++;
          }
        });

        if (limit!=3) {
          window.limitedDetailArray[counter] = tempArray;
        }
        
        window.detailTotal = querySnapshotDetail.lenght;     
        window.detailSteps = Math.round(window.detailTotal/3);

        $('.count-visible-detail').text(3);
        $('.count-total-detail').text(window.detailTotal);         
        
        loadDetails(0);
    });       
    
    }

    function loadDetails(id) {
      window.limitedDetailArray[id].forEach(function(docEdit) {
        renderDetail(docEdit);
      }); 
    } 


    function renderDetail(docEdit) { 
            
      var editData = docEdit.data();              
      window._id_document_collection = editData.id;        
      var _doc_id_ = docEdit.id;              
      window.editDocuments[_doc_id_] = docEdit;                
      let _date = editData.last_update;
      let last_update = getDateFrom(_date.toDate());

      if (editData.html != undefined){
        window.html = editData.html;
      }

      let _icon = editData.icon;                   
      let item = `<tr class="clickable-row-detail"         
      data-short="${_short}" 
      data-name="${editData.name}"             
      data-id="${_doc_id_}">
      <td>
          <span class="custom-checkbox">
              <input type="checkbox" id="${_doc_id_}" value="${_doc_id_}">
              <label for="${document.id}"></label>
          </span>
      </td>                      
      <td>${editData.name}</td>                                            
      <td>`;
      if (!window._is_detail_drawer) {
        item += `<img id="image_${_doc_id_}" class="avatar-preview-list" src="${_icon}" alt="your image" />`;            
      } else {              
        item += `<i id="codepoint" class="material-icons material-icon-picker-prefix prefix">${editData.codepoints}</i>`;
      }            
      item += `</td> 
      <td>${last_update}</td>                                     
      <td>
          <a href="#" id="${_doc_id_}" class="edit js-edit-detail"><i class="material-icons" data-toggle="tooltip" title="Edit">&#xE254;</i>
          </a>
          <a href="#" id="${_doc_id_}" class="delete js-delete-detail" 
          data-name="${editData.name}"             
          data-id="${_doc_id_}"              
          data-short="${_short}"><i class="material-icons" data-toggle="tooltip" title="Delete">&#xE872;</i>
          </a>
      </td>                        
      </tr>`;
      $('#detail-table').append(item);            
      
      // Select/Deselect checkboxes
      let checkbox = $('table tbody input[type="checkbox"]');
      $("#selectAll").click(function () {
          if (this.checked) {
              checkbox.each(function () {
                  console.log(this.id);
                  deleteIDs.push(this.id);
                  this.checked = true;
              });
          } else {
              checkbox.each(function () {
                  this.checked = false;
              });
          }
      });
      checkbox.click(function () {
          if (!this.checked) {
              $("#selectAll").prop("checked", false);
          }
      });

        // VIEW IMAGES
      $(document).on('click', '.clickable-row-detail', function (event) {    

          event.preventDefault();

          if (_clicked == false) {
            
            _clicked = true;        
            window._detail_row_selected = true; 

            let docid = $(this).data("id");              
            let _short = $(this).data("short"); 
            let _name = $(this).data("name"); 

            window._id_document_collection = docid;          
            
            var checkboxes = $('#detail-table tbody input[type="checkbox"]');
            checkboxes.each(function () {
                this.checked = false;
            });

            $(this).find('input[type="checkbox"]').prop("checked", true);  
            $("#btn-contenidos").text(_name);
            $(".multisteps-form__panel").css("opacity","1");

            window.time = setTimeout( function() {                          
                loadEdits(_short);                    
            }, 200);

          }                              
      });
    }

    // Edit Detail
    $(document).on('click', '.js-edit-detail', function (event) {
      event.preventDefault();

      let id = $(this).data('id');
      let _name = $(this).data('name');    
      $('#edit-employee-form').attr('id', id);         
    });
    
    // Delete Detail
    $(document).on('click', '.js-delete-detail', function (event) {
      event.preventDefault();
      
      let id = $(this).data('id');      
      let name = $(this).data('name');
      let ref = $(this).data('ref');
      let short = $(this).data('short');    

      $('#deleteConfirmModal').modal('show');
      $('#delete-element').text(name);   
      $('#delete-detail').data('id', id);   
      $('#delete-detail').data('name', name);   
      $('#delete-detail').data('ref', ref);  
      $('#delete-detail').data('short', short);   
    });

    $("#delete-detail").on("click", function(event) { 
      event.preventDefault();

      let id = $(this).data('id');      
      let name = $(this).data('name');
      let ref = $(this).data('ref');
      let short = $(this).data('short');

      let doc = window.editDocuments[id];
      doc.ref.delete().then(function() {  

        let docRef = database.ref("/" + short + "/" +  ref);
        docRef.remove();        
        $('#deleteConfirmModal').modal('hide');            

      }).catch(function(error) {
        console.error("Error removing document: ", error);
      });        
    });  

    $(document).on('show.bs.modal', '.modal',  function (event) {       

      var input_type;
      if (!window._is_detail_drawer) {
        input_type = `<div id="mediapick" class="form-group">                        
          <label>Thumbnail</label><br>                  
          <input type='file' id="imgInp" name="files[]"/>
          <img id="avatar-preview" class="avatar-preview" src="images/picture.png" alt="your image" />
        </div>`;               
      } else {      
        input_type = `<div id="mediapick" class="form-group">                                  
          <label for="icon">Icono</label>&nbsp;<input type="text" class="use-material-icon-picker" value="android" name="icon">
        </div>`;  
      }
      $("#pictureInput").append(input_type);
      if (window._is_detail_drawer) {
        loadIconPickerCode();
      }
    });


    function loadIconPickerCode() {

        var material_icons = ['3d_rotation', 'ac_unit', 'access_alarm', 'access_alarms', 'access_time', 'accessibility', 'accessible', 'account_balance', 'account_balance_wallet', 'account_box', 'account_circle', 'adb', 'add', 'add_a_photo', 'add_alarm', 'add_alert', 'add_box', 'add_circle', 'add_circle_outline', 'add_location', 'add_shopping_cart', 'add_to_photos', 'add_to_queue', 'adjust', 'airline_seat_flat', 'airline_seat_flat_angled', 'airline_seat_individual_suite', 'airline_seat_legroom_extra', 'airline_seat_legroom_normal', 'airline_seat_legroom_reduced', 'airline_seat_recline_extra', 'airline_seat_recline_normal', 'airplanemode_active', 'airplanemode_inactive', 'airplay', 'airport_shuttle', 'alarm', 'alarm_add', 'alarm_off', 'alarm_on', 'album', 'all_inclusive', 'all_out', 'android', 'announcement', 'apps', 'archive', 'arrow_back', 'arrow_downward', 'arrow_drop_down', 'arrow_drop_down_circle', 'arrow_drop_up', 'arrow_forward', 'arrow_upward', 'art_track', 'aspect_ratio', 'assessment', 'assignment', 'assignment_ind', 'assignment_late', 'assignment_return', 'assignment_returned', 'assignment_turned_in', 'assistant', 'assistant_photo', 'attach_file', 'attach_money', 'attachment', 'audiotrack', 'autorenew', 'av_timer', 'backspace', 'backup', 'battery_alert', 'battery_charging_full', 'battery_full', 'battery_std', 'battery_unknown', 'beach_access', 'beenhere', 'block', 'bluetooth', 'bluetooth_audio', 'bluetooth_connected', 'bluetooth_disabled', 'bluetooth_searching', 'blur_circular', 'blur_linear', 'blur_off', 'blur_on', 'book', 'bookmark', 'bookmark_border', 'border_all', 'border_bottom', 'border_clear', 'border_color', 'border_horizontal', 'border_inner', 'border_left', 'border_outer', 'border_right', 'border_style', 'border_top', 'border_vertical', 'branding_watermark', 'brightness_1', 'brightness_2', 'brightness_3', 'brightness_4', 'brightness_5', 'brightness_6', 'brightness_7', 'brightness_auto', 'brightness_high', 'brightness_low', 'brightness_medium', 'broken_image', 'brush', 'bubble_chart', 'bug_report', 'build', 'burst_mode', 'business', 'business_center', 'cached', 'cake', 'call', 'call_end', 'call_made', 'call_merge', 'call_missed', 'call_missed_outgoing', 'call_received', 'call_split', 'call_to_action', 'camera', 'camera_alt', 'camera_enhance', 'camera_front', 'camera_rear', 'camera_roll', 'cancel', 'card_giftcard', 'card_membership', 'card_travel', 'casino', 'cast', 'cast_connected', 'center_focus_strong', 'center_focus_weak', 'change_history', 'chat', 'chat_bubble', 'chat_bubble_outline', 'check', 'check_box', 'check_box_outline_blank', 'check_circle', 'chevron_left', 'chevron_right', 'child_care', 'child_friendly', 'chrome_reader_mode', 'class', 'clear', 'clear_all', 'close', 'closed_caption', 'cloud', 'cloud_circle', 'cloud_done', 'cloud_download', 'cloud_off', 'cloud_queue', 'cloud_upload', 'code', 'collections', 'collections_bookmark', 'color_lens', 'colorize', 'comment', 'compare', 'compare_arrows', 'computer', 'confirmation_number', 'contact_mail', 'contact_phone', 'contacts', 'content_copy', 'content_cut', 'content_paste', 'control_point', 'control_point_duplicate', 'copyright', 'create', 'create_new_folder', 'credit_card', 'crop', 'crop_16_9', 'crop_3_2', 'crop_5_4', 'crop_7_5', 'crop_din', 'crop_free', 'crop_landscape', 'crop_original', 'crop_portrait', 'crop_rotate', 'crop_square', 'dashboard', 'data_usage', 'date_range', 'dehaze', 'delete', 'delete_forever', 'delete_sweep', 'description', 'desktop_mac', 'desktop_windows', 'details', 'developer_board', 'developer_mode', 'device_hub', 'devices', 'devices_other', 'dialer_sip', 'dialpad', 'directions', 'directions_bike', 'directions_boat', 'directions_bus', 'directions_car', 'directions_railway', 'directions_run', 'directions_subway', 'directions_transit', 'directions_walk', 'disc_full', 'dns', 'do_not_disturb', 'do_not_disturb_alt', 'do_not_disturb_off', 'do_not_disturb_on', 'dock', 'domain', 'done', 'done_all', 'donut_large', 'donut_small', 'drafts', 'drag_handle', 'drive_eta', 'dvr', 'edit', 'edit_location', 'eject', 'email', 'enhanced_encryption', 'equalizer', 'error', 'error_outline', 'euro_symbol', 'ev_station', 'event', 'event_available', 'event_busy', 'event_note', 'event_seat', 'exit_to_app', 'expand_less', 'expand_more', 'explicit', 'explore', 'exposure', 'exposure_neg_1', 'exposure_neg_2', 'exposure_plus_1', 'exposure_plus_2', 'exposure_zero', 'extension', 'face', 'fast_forward', 'fast_rewind', 'favorite', 'favorite_border', 'featured_play_list', 'featured_video', 'feedback', 'fiber_dvr', 'fiber_manual_record', 'fiber_new', 'fiber_pin', 'fiber_smart_record', 'file_download', 'file_upload', 'filter', 'filter_1', 'filter_2', 'filter_3', 'filter_4', 'filter_5', 'filter_6', 'filter_7', 'filter_8', 'filter_9', 'filter_9_plus', 'filter_b_and_w', 'filter_center_focus', 'filter_drama', 'filter_frames', 'filter_hdr', 'filter_list', 'filter_none', 'filter_tilt_shift', 'filter_vintage', 'find_in_page', 'find_replace', 'fingerprint', 'first_page', 'fitness_center', 'flag', 'flare', 'flash_auto', 'flash_off', 'flash_on', 'flight', 'flight_land', 'flight_takeoff', 'flip', 'flip_to_back', 'flip_to_front', 'folder', 'folder_open', 'folder_shared', 'folder_special', 'font_download', 'format_align_center', 'format_align_justify', 'format_align_left', 'format_align_right', 'format_bold', 'format_clear', 'format_color_fill', 'format_color_reset', 'format_color_text', 'format_indent_decrease', 'format_indent_increase', 'format_italic', 'format_line_spacing', 'format_list_bulleted', 'format_list_numbered', 'format_paint', 'format_quote', 'format_shapes', 'format_size', 'format_strikethrough', 'format_textdirection_l_to_r', 'format_textdirection_r_to_l', 'format_underlined', 'forum', 'forward', 'forward_10', 'forward_30', 'forward_5', 'free_breakfast', 'fullscreen', 'fullscreen_exit', 'functions', 'g_translate', 'gamepad', 'games', 'gavel', 'gesture', 'get_app', 'gif', 'golf_course', 'gps_fixed', 'gps_not_fixed', 'gps_off', 'grade', 'gradient', 'grain', 'graphic_eq', 'grid_off', 'grid_on', 'group', 'group_add', 'group_work', 'hd', 'hdr_off', 'hdr_on', 'hdr_strong', 'hdr_weak', 'headset', 'headset_mic', 'healing', 'hearing', 'help', 'help_outline', 'high_quality', 'highlight', 'highlight_off', 'history', 'home', 'hot_tub', 'hotel', 'hourglass_empty', 'hourglass_full', 'http', 'https', 'image', 'image_aspect_ratio', 'import_contacts', 'import_export', 'important_devices', 'inbox', 'indeterminate_check_box', 'info', 'info_outline', 'input', 'insert_chart', 'insert_comment', 'insert_drive_file', 'insert_emoticon', 'insert_invitation', 'insert_link', 'insert_photo', 'invert_colors', 'invert_colors_off', 'iso', 'keyboard', 'keyboard_arrow_down', 'keyboard_arrow_left', 'keyboard_arrow_right', 'keyboard_arrow_up', 'keyboard_backspace', 'keyboard_capslock', 'keyboard_hide', 'keyboard_return', 'keyboard_tab', 'keyboard_voice', 'kitchen', 'label', 'label_outline', 'landscape', 'language', 'laptop', 'laptop_chromebook', 'laptop_mac', 'laptop_windows', 'last_page', 'launch', 'layers', 'layers_clear', 'leak_add', 'leak_remove', 'lens', 'library_add', 'library_books', 'library_music', 'lightbulb_outline', 'line_style', 'line_weight', 'linear_scale', 'link', 'linked_camera', 'list', 'live_help', 'live_tv', 'local_activity', 'local_airport', 'local_atm', 'local_bar', 'local_cafe', 'local_car_wash', 'local_convenience_store', 'local_dining', 'local_drink', 'local_florist', 'local_gas_station', 'local_grocery_store', 'local_hospital', 'local_hotel', 'local_laundry_service', 'local_library', 'local_mall', 'local_movies', 'local_offer', 'local_parking', 'local_pharmacy', 'local_phone', 'local_pizza', 'local_play', 'local_post_office', 'local_printshop', 'local_see', 'local_shipping', 'local_taxi', 'location_city', 'location_disabled', 'location_off', 'location_on', 'location_searching', 'lock', 'lock_open', 'lock_outline', 'looks', 'looks_3', 'looks_4', 'looks_5', 'looks_6', 'looks_one', 'looks_two', 'loop', 'loupe', 'low_priority', 'loyalty', 'mail', 'mail_outline', 'map', 'markunread', 'markunread_mailbox', 'memory', 'menu', 'merge_type', 'message', 'mic', 'mic_none', 'mic_off', 'mms', 'mode_comment', 'mode_edit', 'monetization_on', 'money_off', 'monochrome_photos', 'mood', 'mood_bad', 'more', 'more_horiz', 'more_vert', 'motorcycle', 'mouse', 'move_to_inbox', 'movie', 'movie_creation', 'movie_filter', 'multiline_chart', 'music_note', 'music_video', 'my_location', 'nature', 'nature_people', 'navigate_before', 'navigate_next', 'navigation', 'near_me', 'network_cell', 'network_check', 'network_locked', 'network_wifi', 'new_releases', 'next_week', 'nfc', 'no_encryption', 'no_sim', 'not_interested', 'note', 'note_add', 'notifications', 'notifications_active', 'notifications_none', 'notifications_off', 'notifications_paused', 'offline_pin', 'ondemand_video', 'opacity', 'open_in_browser', 'open_in_new', 'open_with', 'pages', 'pageview', 'palette', 'pan_tool', 'panorama', 'panorama_fish_eye', 'panorama_horizontal', 'panorama_vertical', 'panorama_wide_angle', 'party_mode', 'pause', 'pause_circle_filled', 'pause_circle_outline', 'payment', 'people', 'people_outline', 'perm_camera_mic', 'perm_contact_calendar', 'perm_data_setting', 'perm_device_information', 'perm_identity', 'perm_media', 'perm_phone_msg', 'perm_scan_wifi', 'person', 'person_add', 'person_outline', 'person_pin', 'person_pin_circle', 'personal_video', 'pets', 'phone', 'phone_android', 'phone_bluetooth_speaker', 'phone_forwarded', 'phone_in_talk', 'phone_iphone', 'phone_locked', 'phone_missed', 'phone_paused', 'phonelink', 'phonelink_erase', 'phonelink_lock', 'phonelink_off', 'phonelink_ring', 'phonelink_setup', 'photo', 'photo_album', 'photo_camera', 'photo_filter', 'photo_library', 'photo_size_select_actual', 'photo_size_select_large', 'photo_size_select_small', 'picture_as_pdf', 'picture_in_picture', 'picture_in_picture_alt', 'pie_chart', 'pie_chart_outlined', 'pin_drop', 'place', 'play_arrow', 'play_circle_filled', 'play_circle_outline', 'play_for_work', 'playlist_add', 'playlist_add_check', 'playlist_play', 'plus_one', 'poll', 'polymer', 'pool', 'portable_wifi_off', 'portrait', 'power', 'power_input', 'power_settings_new', 'pregnant_woman', 'present_to_all', 'print', 'priority_high', 'public', 'publish', 'query_builder', 'question_answer', 'queue', 'queue_music', 'queue_play_next', 'radio', 'radio_button_checked', 'radio_button_unchecked', 'rate_review', 'receipt', 'recent_actors', 'record_voice_over', 'redeem', 'redo', 'refresh', 'remove', 'remove_circle', 'remove_circle_outline', 'remove_from_queue', 'remove_red_eye', 'remove_shopping_cart', 'reorder', 'repeat', 'repeat_one', 'replay', 'replay_10', 'replay_30', 'replay_5', 'reply', 'reply_all', 'report', 'report_problem', 'restaurant', 'restaurant_menu', 'restore', 'restore_page', 'ring_volume', 'room', 'room_service', 'rotate_90_degrees_ccw', 'rotate_left', 'rotate_right', 'rounded_corner', 'router', 'rowing', 'rss_feed', 'rv_hookup', 'satellite', 'save', 'scanner', 'schedule', 'school', 'screen_lock_landscape', 'screen_lock_portrait', 'screen_lock_rotation', 'screen_rotation', 'screen_share', 'sd_card', 'sd_storage', 'search', 'security', 'select_all', 'send', 'sentiment_dissatisfied', 'sentiment_neutral', 'sentiment_satisfied', 'sentiment_very_dissatisfied', 'sentiment_very_satisfied', 'settings', 'settings_applications', 'settings_backup_restore', 'settings_bluetooth', 'settings_brightness', 'settings_cell', 'settings_ethernet', 'settings_input_antenna', 'settings_input_component', 'settings_input_composite', 'settings_input_hdmi', 'settings_input_svideo', 'settings_overscan', 'settings_phone', 'settings_power', 'settings_remote', 'settings_system_daydream', 'settings_voice', 'share', 'shop', 'shop_two', 'shopping_basket', 'shopping_cart', 'short_text', 'show_chart', 'shuffle', 'signal_cellular_4_bar', 'signal_cellular_connected_no_internet_4_bar', 'signal_cellular_no_sim', 'signal_cellular_null', 'signal_cellular_off', 'signal_wifi_4_bar', 'signal_wifi_4_bar_lock', 'signal_wifi_off', 'sim_card', 'sim_card_alert', 'skip_next', 'skip_previous', 'slideshow', 'slow_motion_video', 'smartphone', 'smoke_free', 'smoking_rooms', 'sms', 'sms_failed', 'snooze', 'sort', 'sort_by_alpha', 'spa', 'space_bar', 'speaker', 'speaker_group', 'speaker_notes', 'speaker_notes_off', 'speaker_phone', 'spellcheck', 'star', 'star_border', 'star_half', 'stars', 'stay_current_landscape', 'stay_current_portrait', 'stay_primary_landscape', 'stay_primary_portrait', 'stop', 'stop_screen_share', 'storage', 'store', 'store_mall_directory', 'straighten', 'streetview', 'strikethrough_s', 'style', 'subdirectory_arrow_left', 'subdirectory_arrow_right', 'subject', 'subscriptions', 'subtitles', 'subway', 'supervisor_account', 'surround_sound', 'swap_calls', 'swap_horiz', 'swap_vert', 'swap_vertical_circle', 'switch_camera', 'switch_video', 'sync', 'sync_disabled', 'sync_problem', 'system_update', 'system_update_alt', 'tab', 'tab_unselected', 'tablet', 'tablet_android', 'tablet_mac', 'tag_faces', 'tap_and_play', 'terrain', 'text_fields', 'text_format', 'textsms', 'texture', 'theaters', 'thumb_down', 'thumb_up', 'thumbs_up_down', 'time_to_leave', 'timelapse', 'timeline', 'timer', 'timer_10', 'timer_3', 'timer_off', 'title', 'toc', 'today', 'toll', 'tonality', 'touch_app', 'toys', 'track_changes', 'traffic', 'train', 'tram', 'transfer_within_a_station', 'transform', 'translate', 'trending_down', 'trending_flat', 'trending_up', 'tune', 'turned_in', 'turned_in_not', 'tv', 'unarchive', 'undo', 'unfold_less', 'unfold_more', 'update', 'usb', 'verified_user', 'vertical_align_bottom', 'vertical_align_center', 'vertical_align_top', 'vibration', 'video_call', 'video_label', 'video_library', 'videocam', 'videocam_off', 'videogame_asset', 'view_agenda', 'view_array', 'view_carousel', 'view_column', 'view_comfy', 'view_compact', 'view_day', 'view_headline', 'view_list', 'view_module', 'view_quilt', 'view_stream', 'view_week', 'vignette', 'visibility', 'visibility_off', 'voice_chat', 'voicemail', 'volume_down', 'volume_mute', 'volume_off', 'volume_up', 'vpn_key', 'vpn_lock', 'wallpaper', 'warning', 'watch', 'watch_later', 'wb_auto', 'wb_cloudy', 'wb_incandescent', 'wb_iridescent', 'wb_sunny', 'wc', 'web', 'web_asset', 'weekend', 'whatshot', 'widgets', 'wifi', 'wifi_lock', 'wifi_tethering', 'work', 'wrap_text', 'youtube_searched_for', 'zoom_in', 'zoom_out', 'zoom_out_map'];

        $('input[type="text"].use-material-icon-picker').each(function () {
          // Add the current icon as a prefix, and update when the field changes.
          $(this).before('<i class="material-icons material-icon-picker-prefix prefix"></i>');
          $(this).on('change keyup', function () {
            $(this).prev().text($(this).val());
          });
          $(this).prev().text($(this).val());
          // Append the picker and the search box.
          var $picker = $('<div class="material-icon-picker" tabindex="-1"></div>');
          var $search = $('<input type="text" placeholder="Search...">');
          // Do simple filtering based on the search.
          $search.on('keyup', function () {
            var search = $search.val().toLowerCase();
            var $icons = $(this).siblings('.icons');
            $icons.find('i').css('display', 'none');
            $icons.find('i:contains('+search+')').css('display', 'inline-block');
          });
          $picker.append($search);
          // Append each icon into the picker.
          var $icons = $('<div class="icons"></div>');
          function onIconClick() {
            $(this).closest('.material-icon-picker').prev().val($(this).text()).trigger('change');
          }
          material_icons.forEach(function (icon) {
            var $icon = $('<i class="material-icons"></i>');
            $icon.text(icon);
            $icon.on('click', onIconClick);
            $icons.append($icon);
          });
          // Show the picker when the input field gets focus.
          $picker.append($icons).hide();
          $(this).after($picker);
          $(this).on('focusin', function () {
            $picker.fadeIn(200);
          });
        });
        // Hide any picker when it or the input field loses focus.
        $(document).on('mouseup', function (e) {
          var $picker = $('.material-icon-picker');
          if ($picker.length && !$picker.is(e.target) && !$(e.target).hasClass('use-material-icon-picker') && $picker.has(e.target).length === 0) {
            $picker.fadeOut(200);
          }
        });
    }


    function getDateFrom(_date) {      

        var year = _date.getFullYear();
        var month = _date.getMonth()+1;
        var day = _date.getDate();

        if (day < 10) {
          day = '0' + day;
        }
        if (month < 10) {
          month = '0' + month;
        }
        var formattedDate = day + '-' + month + '-' + year;
        return formattedDate;
      }

      function formatDate(date) {
          var d = new Date(date),
              month = '' + (d.getMonth() + 1),
              day = '' + d.getDate(),
              year = d.getFullYear();
      
          if (month.length < 2) 
              month = '0' + month;
          if (day.length < 2) 
              day = '0' + day;
      
          return [day, month, year].join('-');
      }     
      
      // Publish
      $('#button-publish').click(function(event) { 
        event.preventDefault();
        $('#publishModal').modal('show');        
      });

      $('#detailModal').on('hidden.bs.modal', function () {
        $("#mediapick").remove();
      });    
      
      var icons = [];

      $('#detailModal').on('show.bs.modal', function () {
        if (window._is_detail_drawer) {
          fetch('./json/icons.json').then(res => res.json()).then(data => {            
            console.log(data);
            icons = data;
          }).catch(err => console.error(err));
        }    
      });

      function getIconCode(name) {
        let obj = icons.filter(item => item.name === name);
        return "0x" +  obj[0].code;
      }

      $('#acceptCheckbox').change(function() {
        if ($(this).prop('checked')) {
          $('#button-accept').prop('disabled', false);       
        } else  {
          $('#button-accept').prop('disabled', true);
        }
      });

      $('#button-accept').click(function(event) { 
        event.preventDefault();  
        
        var _time =  new Date();       
        db.collection('contents')
          .doc(window._short)
          .collection("collection")
          .doc(window._id_document_collection)
          .update({        
            "approved" : false,
            "published" : false,
            "last_update" : _time        
        }).then(function(documentUpdated) {
          $('#publishModal').modal('hide');
        }).catch(function(error) {
          console.error("Error adding document: ", error);
        });
      });

      $('#button-save').click(function(event) {     
        event.preventDefault();  
        
        var settings = {
            "url": "https://us-central1-curupas-app.cloudfunctions.net/publish",
            "method": "POST",
            "timeout": 0,
            "headers": {
              "Content-Type": "application/json"
            },
            "data": JSON.stringify({
              "contentType":window._short,
              "documentId":window._id_document_collection
            }),
          };
          homeLoader.show();            
          $.ajax(settings).done(function (response) {
            console.log(response);
            if (response.data.result) {
              homeLoader.hide();  
              window.html = response.data.html;           
            }             
          });     
      });

      $('#view-save').click(function() {           
        $('#previewModal').modal('show');
        $('#preview-content').append("<div id='modal-container'>" + window.html + "</div>");
      });

      $('#previewModal').on('hidden.bs.modal', function () {
        $('#preview-content').remove();
      });         
      
      function loadEdits(_short) {        

        clearTimeout(window.time);
        _clicked = false;

        var firepad_userlist_div = $( "<div id='firepad-userlist'></div>" );        
        let firepad_div = $(`<textarea id="basic-example"></textarea>`);                

        $( "#firepad-container" ).append( firepad_userlist_div );
        $( "#firepad-container").append( firepad_div );          

        window.time = setTimeout( function() {               
          
          // TINYMCE       
          tinymce.init({
            selector: 'textarea#basic-example',
            menubar: false,
            height: 600,
            element_format: 'html',            
            plugins: [
              'advlist autolink lists link image charmap print preview anchor',
              'searchreplace visualblocks code fullscreen',
              'insertdatetime media table paste code wordcount'
            ],            
            toolbar: 'undo redo | formatselect | ' +
            'bold italic backcolor | alignleft aligncenter ' +
            'alignright alignjustify | bullist numlist outdent indent | ' +
            'removeformat | imageUpload imageInsert ', // | helloworld',            
            //menubar: 'insert help',
            /*menu: {
              insert: {title: 'Insert', items: 'helloworld'},
            },*/
            setup: function(editor) {
              clearTimeout(window.time);            
              
              editor.on('change', function(ed) {               

              });              

              editor.ui.registry.addButton('imageUpload', {
                icon: 'upload',
                text: 'Subir imagenes',
                tooltip: 'Subir Imagen',
                onAction: function (_) {
                  //editor.insertContent();//toDateHtml(new Date()));
                  $("#uploadImageModal").modal("show");
                }
              });
            
              editor.ui.registry.addButton('imageInsert', {
                icon: 'image',
                text: 'Insertar',
                tooltip: 'Insertar Imagen',
                onAction: function (_) {
                  //editor.insertContent();//toDateHtml(new Date()));
                  $("#insertImageModal").modal("show");

                  $(".modal .modal-dialog").css("max-width", "800px");

                  $("#insert-picker").empty();

                  db.collection('contents')
                  .doc(window._short)
                  .collection("collection")
                  .doc(window._id_document_collection)                
                  .get().then(function (snap) { 

                      var _images = snap.data().images;

                      var lenght = _images.length;
                      
                      if ( lenght > 0 ) {

                        for (var i=0; i < lenght; i++) {
                          
                          let picheck = `<div class="col-xs-4 col-sm-3 col-md-2 nopad text-center">
                              <label class="image-checkbox">
                                  <img class="img-responsive" src="${_images[i]}">
                                  <input name="image[]" value="" type="checkbox">                                  
                              </label>
                          </div>`;
                          $("#insert-picker").append(picheck);

                          window.array_images_selected = new Array();

                          if (i==(length-1)) {

                            window.time = setTimeout( function() {                          

                              //https://stackoverflow.com/questions/48379838/bootstrap-image-with-checkbox
                              
                              $(".image-checkbox").each(function () {
                                if ($(this).find('input[type="checkbox"]').first().attr("checked")) {
                                    $(this).addClass('image-checkbox-checked');
                                } else {
                                    $(this).removeClass('image-checkbox-checked');
                                }
                              });
                          
                              // sync the state to the input
                              $(".image-checkbox").on("click", function (e) {
                                  $(this).toggleClass('image-checkbox-checked');   
                                  let src = $(this).find('img').attr("src");  
                                  if ($(this).hasClass( "image-checkbox-checked" )) {
                                      window.array_images_selected.push(src);
                                  } else {
                                     window.array_images_selected = window.array_images_selected.filter(e => e !== src);
                                  }                            
                                  e.preventDefault();
                              });

                              clearTimeout(window.time);

                            }, 1000); 
                          }
                        }
                      }
                  });
                }
              });
                    
              /** Campos **/              
              editor.ui.registry.addMenuButton('campos', {
                text: 'Campos',
                fetch: function(callback) {
                  var items = [];
                  for (var fieldName in camposFields) {
                    var menuItem = {
                      type: 'menuitem',
                      text: camposFields[fieldName],
                      value:fieldName,
                      onSetup: function(buttonApi) {
                        var $this = this;
                        this.onAction = function() {
                          editor.insertContent($this.data.value);
                        };
                      },
                    };
                    items.push(menuItem);
                  }
                  callback(items);
                },
              });
          }
        });
          
      }, 500);            
    } 
       

    document.getElementById('proImage').addEventListener('change', addImageToPreviewFromFile, false);      

    $(document).on('click', '.image-cancel', function() {
        let no = $(this).data('no');
        $(".preview-image.preview-show-"+no).remove();
    });    
    
    var num = 4;

    function addImageToPreviewFromFile() {
        if (window.File && window.FileList && window.FileReader) {
            var files = event.target.files;             
            var output = $(".preview-images-zone");    
            for (let i = 0; i < files.length; i++) {
                var file = files[i];
                if (!file.type.match('image')) continue;                
                var picReader = new FileReader();                
                picReader.addEventListener('load', function (event) {
                    var picFile = event.target;
                    var html =  '<div data-type="1" class="preview-image preview-show-' + num + '">' +
                                '<div class="image-cancel" data-no="' + num + '">x</div>' +
                                '<div class="image-zone"><img id="pro-img-' + num + '" src="' + picFile.result + '"></div>' +
                                '<div class="tools-edit-image"><a href="javascript:void(0)" data-no="' + num + '" class="btn btn-light btn-edit-image">edit</a></div>' +
                                '</div>';
    
                    output.append(html);
                    num = num + 1;
                });
    
                picReader.readAsDataURL(file);
            }
            $("#pro-image").val('');
        } else {
            console.log('Browser not support');
        }
    }

    $('#upload-image-from-url').click(function() {      
      let url = $("#image-url").val();
      $("#image-url").val("");
      addImageToPreviewFromUrl(url);
    }); 

    function addImageToPreviewFromUrl(url) {      
        var output = $(".preview-images-zone");    
        var html =  '<div data-type="2" class="preview-image preview-show-' + num + '">' +
                    '<div class="image-cancel" data-no="' + num + '">x</div>' +
                    '<div class="image-zone"><img id="pro-img-' + num + '" src="' + url + '"></div>' +
                    '<div class="tools-edit-image"><a href="javascript:void(0)" data-no="' + num + '" class="btn btn-light btn-edit-image">edit</a></div>' +
                    '</div>';
        output.append(html);
        num = num + 1;
    }

    function readURL(input) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();            
            reader.onload = function (e) {
                $('#avatar-preview').attr('src', e.target.result);
            }            
            reader.readAsDataURL(input.files[0]);
        }
    }
    
    $("#imgInp").change(function(){
        readURL(this);
    });  
    
    // Add Images 
    $("#btn-upload-close").add("#btn-upload-close-x").on('click', function (event) {
      event.preventDefault();         
      $('#uploadImageModal').modal('hide');
    });
          
    $('#btn-upload-save').on('click', function(event) {  
      event.preventDefault();              

      let _imagePath = "contents/" + window._short + "/" + window._id_document_collection + "/images";
      var storageRef = storage.ref(_imagePath);     
      var metadataFiles = {
          customMetadata: {
              'thumbnail': 'false',
              'type' : '2', 
              'id' : window._id_document_collection,
              'short' : window._short                   
          }
      };

      var input = document.getElementById("proImage");
      var prefArray = [];        
      var k=0;      
      var count_input = 0;         
      var previewList = $(".preview-image");
      let length = previewList.length;
      
      previewList.each(function( index ) {    
        
        let data_type = $(this).attr("data-type");

        if (data_type==1) {

          //from file
        
          var file_uploaded = input.files.item(count_input);            
          uploadImageToStorage(file_uploaded);
          count_input++;

        } else if (data_type==2)  {

          //from internet

          let _imgeURL = $(this).find("img").attr('src');
          convertToDataURLviaCanvas(_imgeURL, function(dataUrl) {            
            var stripped = dataUrl.slice(22);
            var blob = b64toBlob(stripped, 'image/png');
            uploadImageToStorage(blob);            
          });
          
        }

      });  
      
      function b64toBlob(b64Data, contentType, sliceSize) {
        var byteCharacters = atob(b64Data);
        var byteArrays = [];
      
        contentType = contentType || '';
        sliceSize = sliceSize || 512;
      
        for (var offset = 0; offset < byteCharacters.length; offset += sliceSize) {
          var slice = byteCharacters.slice(offset, offset + sliceSize);
          var byteNumbers = new Array(slice.length);
          var byteArray;
      
          for (var i = 0; i < slice.length; i++) {
            byteNumbers[i] = slice.charCodeAt(i);
          }
      
          byteArray = new Uint8Array(byteNumbers);
          byteArrays.push(byteArray);
        }
      
        var blob = new Blob(byteArrays, {type: contentType});
        return blob;
      }
      
      function convertToDataURLviaCanvas(url, callback) {
        var img = new Image();
      
        img.crossOrigin = 'Anonymous';
        img.onload = function(){
          var canvas = document.createElement('canvas');
          var ctx = canvas.getContext('2d');
          var dataURL;
      
          canvas.height = this.height;
          canvas.width = this.width;
          ctx.drawImage(this, 0, 0);
          dataURL = canvas.toDataURL();
          callback(dataURL);
          canvas = null; 
        };
        img.src = url;
      }

     
      function uploadImageToStorage(_file) {

        let rnd = Math.floor((Math.random()) * 0x10000).toString(7);                                                              
        var filePath = window._short + "_" +  rnd + ".png";                          
        const museumRef = storageRef.child(filePath);
        const putRef = museumRef.put(_file, metadataFiles);              
        prefArray.push(putRef);  
        putRef.on('state_changed', function(snapshot) {
          var progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          console.log('Upload is ' + progress + '% done');
          switch (snapshot.state) {
            case firebase.storage.TaskState.PAUSED: // or 'paused'
              console.log('Upload is paused');
              break;
            case firebase.storage.TaskState.RUNNING: // or 'running'
              console.log('Upload is running');
              break;
          }
        }, function(error) {                
          console.error("Error loading image: ", error);
        }, function() {                                       
          console.error("Image uploaded succesfully");                
          if (k==(length-1)){
              $('#uploadImageModal').modal('hide'); 
          }
          k++; 
        }); 
      }           
    });

    //Add Main Modal      
    $("#btn-main-close").add("#btn-main-close-x").on('click', function (event) {
      event.preventDefault();   
      $("#addCategoryModal").hide();
    });

    $("#btn-main-save").on('click', function (event) {
      event.preventDefault();  

      let _name = $("#category-name").val();
      let _desc = $("#category-description").val();
      let _new = $("#category-new").val();

      let _short = _name.toLowerCase();      
      let docRef = db.collection("contents").doc(_short);
      var now = firebase.firestore.FieldValue.serverTimestamp();
      
      return docRef.set({
        name: _name,
        short: _short,
        desc: _desc,
        new: _new,
        amount:0,
        last_update: now,      
        time_created: now 
      }).then(docRefSet => {            
        
        $('#main-table').empty();
        $("#addCategoryModal").hide();
        loadData();
        
      }).catch((error) => {     
        console.error("Error adding document: ", error);           
      });   
    });  

    //Add Detail Modal    
    $("#btn-detail-close").add("#btn-detail-close-x").on('click', function (event) {
      event.preventDefault();   
      $("#addDetailModal").hide();
    });

    $("#btn-detail-save").on('click', function (event) {
      event.preventDefault();  

      var new_name = $('#new-name').val();
      var new_desc = $('#new-desc').val();
      var document_path = "contents/" + window._short + "/collection";            
      var _time =  new Date();
      var timestamp =  new Date();
      var thedate = getDateFrom(timestamp);      

      let row = { "meta": {            
        "id" : window._short,
        "Nombre": new_name, 
        "Desc": new_desc, 
        "Actualizado": thedate } };   

      window.jsonDataDetail.push(row);

      var newData = {            
        group_ref : _user.yearReference,
        name : new_name,
        description : new_desc,          
        last_update : _time          
      };

      if (window._is_detail_drawer) {           
        let codepoint = $("#codepoint").text();             
        newData['codepoints'] = codepoint;
        let code = getIconCode(codepoint);
        newData['icon'] = code;
      } 

      db.collection(document_path).add(newData).then(function(doc){   

          if (!window._is_detail_drawer) {  
        
            let _id = doc.id;          
            var storage_path = "contents/" + window._short + "/" + _id;
            var storageRef = storage.ref(storage_path);        
            var file = window.document.getElementById("imgInp").files[0];                 
            let rnd = Math.floor((Math.random()) * 0x10000).toString(7);           
            var filePath = window._short + "_" +  new_name.split(' ').join('_').toLowerCase() + "_" + rnd + ".png";                        
            var thisRef = storageRef.child(filePath);                         

            var metadata = {
                customMetadata: {
                    'thumbnail': 'true',
                    'type' : '3',
                    'short' : window._short,
                    'id' : _id                   
                }
            };
            thisRef.put(file, metadata);
          }    

          let _document = window.editObjects[_short];
          let data_amount =  _document.data().amount;                     
          let _amount = parseInt(data_amount);
          _amount++;                     

          window.editObjects[_short].ref.set({             
              amount:_amount }
            ,{ merge:true }
          ).then(function() {

            $('#addDetailModal').modal('hide');
            //REFRESH PAGE COMPULSORY
            location.reload(true);               
            //THIS SHOULD BE RELOADED
            //reloadDetails(_short);    

          }).catch((error) => {
            console.log('Error setting amount:', error);                
          });  
        
      }).catch(function(error) {
        console.error("Error getting collection: ", error);
      }); 

    });

    function reloadDetails(short) {     

      db.collection("contents").doc(short)
        .get().then(function (snap) {  
          
          var _new = snap.data().new;
          var document_path = "contents/" + short + "/collection";                     
          db.collection(document_path).get().then(function (documentSnapshots) {                     
            var count = 0;
            var length = documentSnapshots.docs.length;
            documentSnapshots.docs.forEach(function(document) {          
              
              if (count==(length-1)) {                 
                window.editObjects[short] = document;               
                //let _doc = document.data();                                             
                loadEditsList(_new, short);                          
              }                          
              count++;            
            });
            window.mainPartial = documentSnapshots.docs.length;
        });
      }); 
    }

    
    
  // Spinner
  function modal(){
    $('.modal').modal('show');
    var _time = setTimeout(function () {
      console.log('hejF');
      $('.modal').modal('hide');
      clearTimeout(_time);
    }, 3000);
  }
    
  // Bootstrap Stepper 
  //https://webdevtrick.com/bootstrap-multi-step-form-animations/

  const DOMstrings = {
    stepsBtnClass: 'multisteps-form__progress-btn',
    stepsBtns: document.querySelectorAll(`.multisteps-form__progress-btn`),
    stepsBar: document.querySelector('.multisteps-form__progress'),
    stepsForm: document.querySelector('.multisteps-form__form'),
    stepsFormTextareas: document.querySelectorAll('.multisteps-form__textarea'),
    stepFormPanelClass: 'multisteps-form__panel',
    stepFormPanels: document.querySelectorAll('.multisteps-form__panel'),
    stepPrevBtnClass: 'js-btn-prev',
    stepNextBtnClass: 'js-btn-next' };

  window.activePanelNum = 0;

  const removeClasses = (elemSet, className) => {    
    elemSet.forEach(elem => {    
      elem.classList.remove(className);    
    });    
  };

  const findParent = (elem, parentClass) => {    
    let currentNode = elem;    
    while (!currentNode.classList.contains(parentClass)) {
      currentNode = currentNode.parentNode;
    }    
    return currentNode;    
  };

  const getActiveStep = elem => {
    return Array.from(DOMstrings.stepsBtns).indexOf(elem);
  };

  const setActiveStep = activeStepNum => {    
    removeClasses(DOMstrings.stepsBtns, 'js-active');    
    DOMstrings.stepsBtns.forEach((elem, index) => {    
      if (index <= activeStepNum) {
          elem.classList.add('js-active');
      }    
    });
  };

  const getActivePanel = () => {    
    let activePanel;    
    DOMstrings.stepFormPanels.forEach(elem => {    
      if (elem.classList.contains('js-active')) {      
          activePanel = elem;      
      }    
    });    
    return activePanel;    
  };

  const setActivePanel = activePanelNum => {    
    removeClasses(DOMstrings.stepFormPanels, 'js-active');    
    DOMstrings.stepFormPanels.forEach((elem, index) => {
      if (index === activePanelNum) {      
          elem.classList.add('js-active');      
          setFormHeight(elem);      
      }
    });    
  };

  const formHeight = activePanel => {    
    var activePanelHeight = activePanel.offsetHeight;        
    if (window.activePanelNum==2) {
        $("#columna").removeClass("col-lg-8");                        
        //$('#firepadform').height(1500);            
    } else {
        $("#columna").addClass("col-lg-8");
    }    
    DOMstrings.stepsForm.style.height = `${activePanelHeight}px`;            
  };

  const setFormHeight = () => {
    const activePanel = getActivePanel();    
    formHeight(activePanel);
  };

  DOMstrings.stepsBar.addEventListener('click', e => {    
    const eventTarget = e.target;    
    if (!eventTarget.classList.contains(`${DOMstrings.stepsBtnClass}`)) {
      return;
    }   
    const activeStep = getActiveStep(eventTarget);    
    setActiveStep(activeStep);    
    setActivePanel(activeStep);
  });

  DOMstrings.stepsForm.addEventListener('click', e => {   
    const eventTarget = e.target;        
    if (!(eventTarget.classList.contains(`${DOMstrings.stepPrevBtnClass}`)))  {        
      if (!window._main_row_selected && window.activePanelNum==0) {
          return;
      }    
      if (!window._detail_row_selected && window.activePanelNum==1) {
        return;
      }          
      if (!(eventTarget.classList.contains(`${DOMstrings.stepPrevBtnClass}`) || eventTarget.classList.contains(`${DOMstrings.stepNextBtnClass}`))) {
        return;
      }
    }      
    const activePanel = findParent(eventTarget, `${DOMstrings.stepFormPanelClass}`);    
    window.activePanelNum = Array.from(DOMstrings.stepFormPanels).indexOf(activePanel);    
    if (eventTarget.classList.contains(`${DOMstrings.stepPrevBtnClass}`)) {
        window.activePanelNum--;    
    } else {    
      window.activePanelNum++;       
    }    

    let button_name_detail;
    if (window.activePanelNum==0) {
      button_name_detail = "contenido";      
      $('#btn-contenidos').text('Contenidos'); 
    } else if (window.activePanelNum==1) {      
      button_name_detail = window._detail_name;
    }    
    $('#button-add-detail-text').text('Agregar ' + button_name_detail); 

    setActiveStep(window.activePanelNum);
    setActivePanel(window.activePanelNum);    
  });        

  const setAnimationType = newType => {
    DOMstrings.stepFormPanels.forEach(elem => {
      elem.dataset.animation = newType;
    });
  };  

  // PAGINATION
  window.detailActiveTable = 0;
  window.detailTotal = 0;
  window.detailSteps = 0;
  window.detailPartial = 0;

  $('#js-next-detail').on('click', function () {                  
    window.detailActiveTable++;         
    if ($(this).closest('.page-item').hasClass('disabled')) {
        return false;
    }      
    $('#detail-table tbody').html('');
    loadDetails(window.detailActiveTable);
    window.detailPartial = (window.detailPartial + length);
    $('.count-visible-detail').text(window.detailPartial);        
    if (window.detailSteps == window.detailActiveTable) {
      $('#js-next-detail').closest('.page-item').addClass('disabled');
    }              
    if (!window._main_row_selected && window.activePanelNum==0) {
      return;
    }    
    if (!window._detail_row_selected && window.activePanelNum==1) {
      return;
    }   
  });

  // PAGINATION
  $("#js-previous-detail").on('click', function () {

    window.detailActiveTable--;
    $('#detail-table tbody').html('');
    loadDetails(window.detailActiveTable); 
    if (window.detailActiveTable == 0) {
      window.detailPartial = documentSnapshots.docs.length;            
    } 
    $('.count-visible-detail').text(window.detailPartial);  
    if (window.detailActiveTable == 0) {
      $('#js-next-detail').closest('.page-item').removeClass('disabled');
    }
  });

  // UPLOAD FILE
  // https://webdevtrick.com/jquery-drag-and-drop-file-upload/      

  // Code By Webdevtrick ( https://webdevtrick.com )
  function readFile(input) {
    if (input.files && input.files[0]) {
      var reader = new FileReader();

      reader.onload = function(e) {
        var htmlPreview =
          '<img width="200" src="' + e.target.result + '" />' +
          '<p>' + input.files[0].name + '</p>';
        var wrapperZone = $(input).parent();
        var previewZone = $(input).parent().parent().find('.preview-zone');
        var boxZone = $(input).parent().parent().find('.preview-zone').find('.box').find('.box-body');

        wrapperZone.removeClass('dragover');
        previewZone.removeClass('hidden');
        boxZone.empty();
        boxZone.append(htmlPreview);
      };

      reader.readAsDataURL(input.files[0]);
    }
  }

  function reset(e) {
    e.wrap('<form>').closest('form').get(0).reset();
    e.unwrap();
  }

  $(".dropzone").change(function() {
    readFile(this);
  });

  $('.dropzone-wrapper').on('dragover', function(e) {
    e.preventDefault();
    e.stopPropagation();
    $(this).addClass('dragover');
  });

  $('.dropzone-wrapper').on('dragleave', function(e) {
    e.preventDefault();
    e.stopPropagation();
    $(this).removeClass('dragover');
  });

  $('.remove-preview').on('click', function() {
    var boxZone = $(this).parents('.preview-zone').find('.box-body');
    var previewZone = $(this).parents('.preview-zone');
    var dropzone = $(this).parents('.form-group').find('.dropzone');
    boxZone.empty();
    previewZone.addClass('hidden');
    reset(dropzone);
  });
      
  //# sourceURL=textedit.js   

});



































