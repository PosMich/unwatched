angular.module('unwatched').run(['$templateCache', function($templateCache) {
  'use strict';

  $templateCache.put('/partials/chat.jade',
    ".panel.panel-default.chat-container(ng-controller=\"ChatCtrl\",\n" +
    "    ng-class=\"chat.state\",\n" +
    "    rearange-container=\"chat.state\")\n" +
    "\n" +
    "    .panel-heading(ng-click=\"chat.maximize()\")\n" +
    "        | Roomname - Chat\n" +
    "    .controls.pull-right\n" +
    "        i.fa.fa-compress(ng-click=\"chat.compress()\",\n" +
    "            ng-show=\"chat.state == 'expanded'\")\n" +
    "        i.fa.fa-expand(ng-click=\"chat.expand()\",\n" +
    "            ng-show=\"chat.state == 'compressed'\")\n" +
    "        i.fa.fa-minus(ng-hide=\"chat.state == 'minimized'\", \n" +
    "            ng-click=\"chat.minimize()\")\n" +
    "\n" +
    "    .panel-body \n" +
    "        .message-container(update-scroll-position=\"chat.messages.length\")\n" +
    "            div\n" +
    "                .clearfix.chat-message(\n" +
    "                    ng-repeat=\"message in chat.messages\")\n" +
    "                    span.well.well-sm(ng-class-even=\"'own'\")\n" +
    "                        | <b>{{message.sender}}:</b> {{message.content}}\n" +
    "    .panel-footer.message-control.clearfix\n" +
    "        form(name=\"chatMessage\", no-validate, \n" +
    "            ng-submit=\"submitChatMessage()\")\n" +
    "            .control-input\n" +
    "                input#inputChatMessage.form-control(type=\"text\", \n" +
    "                    required, ng-model=\"chat.message\")\n" +
    "            .control-button\n" +
    "                a.btn.btn-default(ng-disabled=\"chatMessage.$invalid\", \n" +
    "                    focus-on-click=\"input-chat-message\", ng-href=\"#\",\n" +
    "                    ng-click=\"submitChatMessage()\")\n" +
    "                    i.fa.fa-share"
  );


  $templateCache.put('/partials/index.jade',
    ".info-container(center-vertical)\n" +
    "    .info\n" +
    "        | Chat with others\n" +
    "    .info\n" +
    "        | Share anything\n" +
    "\n" +
    "#create-room-container.well(center-vertical)\n" +
    "    form.form-horizontal(novalidate, name=\"createRoom\")\n" +
    "        fieldset\n" +
    "            legend Create Room\n" +
    "            .form-group\n" +
    "                .col-xs-1\n" +
    "                label.col-xs-4.control-label(for='roomName') Room Name\n" +
    "                .col-xs-6.col-offset-xs-1(ng-class=\"{'has-error': createRoom.rName.$invalid && createRoom.rName.$dirty}\")\n" +
    "                    input#roomName.form-control(type='text', name=\"rName\"\n" +
    "                        ng-model=\"room.name\", placeholder='Room Name',\n" +
    "                        ng-minlength=\"5\", required)\n" +
    "                    span.help-block(ng-show=\"createRoom.rName.$error.required && createRoom.rName.$dirty\")\n" +
    "                        | *Required field.\n" +
    "                    span.help-block(ng-show=\"createRoom.rName.$error.minlength && createRoom.rName.$dirty\")\n" +
    "                        | *Type in at least 5 characters.\n" +
    "\n" +
    "            .form-group\n" +
    "                .col-xs-1\n" +
    "                label.col-xs-4.control-label(for='roomPassword')\n" +
    "                    | Password\n" +
    "                .col-xs-6.col-offset-xs-1(ng-class=\"{'has-error': createRoom.rPassword.$invalid && createRoom.rPassword.$dirty}\")\n" +
    "                    input#roomPassword.form-control(type='password',\n" +
    "                        name=\"rPassword\" ng-model=\"room.password\",\n" +
    "                        placeholder='Password', ng-minlength=\"5\", required)\n" +
    "                    span.help-block(ng-show=\"createRoom.rPassword.$error.required && createRoom.rPassword.$dirty\")\n" +
    "                        | *Required field.\n" +
    "                    span.help-block(ng-show=\"createRoom.rPassword.$error.minlength && createRoom.rPassword.$dirty\")\n" +
    "                        | *Type in at least 5 characters.\n" +
    "            .form-group\n" +
    "                .col-xs-1\n" +
    "                label.col-xs-4.control-label(for='roomPasswordRepeat')\n" +
    "                    | Repeat Password\n" +
    "                .col-xs-6.col-offset-xs-1(ng-class=\"{'has-error': createRoom.rPasswordRepeat.$invalid && createRoom.rPasswordRepeat.$dirty}\")\n" +
    "                    input#roomPasswordRepeat.form-control(type='password',\n" +
    "                        name=\"rPasswordRepeat\", ng-model=\"room.passwordRepeat\",\n" +
    "                        placeholder='Repeat Password', \n" +
    "                        input-match=\"roomPassword\", required)\n" +
    "                    span.help-block(ng-show=\"createRoom.rPasswordRepeat.$error.required && createRoom.rPasswordRepeat.$dirty\")\n" +
    "                        | *Required field.\n" +
    "                    span.help-block(ng-show=\"createRoom.rPasswordRepeat.$error.inputMatch && createRoom.rPasswordRepeat.$dirty && !createRoom.rPasswordRepeat.$error.required\")\n" +
    "                        | Passwords don't match.\n" +
    "                    \n" +
    "            .form-group\n" +
    "                .col-offset-xs-2.col-xs-9.col-offset-xs-1\n" +
    "                    button.btn.btn-primary.pull-right(type='submit',\n" +
    "                    ng-disabled=\"createRoom.$invalid\") Submit\n"
  );


  $templateCache.put('/partials/loginForm.jade',
    ".modal-header\n" +
    "  h3 Login\n" +
    ".modal-body\n" +
    "  fieldset\n" +
    "    form.form-horizontal(name=\"login\", novalidate, ng-ctrl=\"SignUpCtrl\")\n" +
    "      .form-group(ng-class=\"{'has-error' : login.email.$error.email}\")\n" +
    "        label.col-sm-4.control-label(for='inputEmail') Email\n" +
    "        .col-sm-6\n" +
    "          input#inputEmail.form-control(type='email', ng-model=\"user.email\", \n" +
    "            name=\"email\", placeholder='Email', required)\n" +
    "\n" +
    "      .form-group(ng-class=\"{'has-error' : login.password.$error.minlength}\")\n" +
    "        label.col-sm-4.control-label(for='inputPassword') Password\n" +
    "        .col-sm-6\n" +
    "          input#inputPassword.form-control(type='password', ng-minlength=\"5\",\n" +
    "            name=\"password\", ng-model=\"user.password\", placeholder='Password', \n" +
    "            required)\n" +
    "\n" +
    "    form.form-horizontal(name=\"signup\", novalidate, ng-ctrl=\"SignUpCtrl\")\n" +
    "      #signup-fields-container(collapse=\"hideSignUp\")\n" +
    "        .form-group(ng-class=\"{'has-error' : signup.confirmEmail.$error.email || signup.confirmEmail.$error.inputMatch}\")\n" +
    "          label.col-sm-4.control-label(for='inputEmailConfirm') Confirm Email\n" +
    "          .col-sm-6\n" +
    "            input#inputConfirmEmail.form-control(type='email', \n" +
    "              name=\"confirmEmail\", ng-minlength=\"5\", input-match=\"inputEmail\"\n" +
    "              ng-model=\"user.confirmEmail\", placeholder='Confirm Email', \n" +
    "              required)\n" +
    "\n" +
    "        .form-group(ng-class=\"{'has-error' : signup.confirmPassword.$error.minlength || signup.confirmPassword.$error.inputMatch}\")\n" +
    "          label.col-sm-4.control-label(for='inputConfirmPassword') Confirm Password\n" +
    "          .col-sm-6\n" +
    "            input#inputConfirmPassword.form-control(type='password', \n" +
    "              name=\"confirmPassword\", ng-minlength=\"5\", input-match=\"inputPassword\"\n" +
    "              ng-model=\"user.confirmPassword\", placeholder='Confirm Password', \n" +
    "              required)\n" +
    "\n" +
    "        .form-group(ng-class=\"{'has-error' : signup.displayName.$error.minlength}\")\n" +
    "          label.col-sm-4.control-label(for='inputDisplayName') Display Name\n" +
    "          .col-sm-6\n" +
    "            input#inputDisplayName.form-control(type='text', ng-minlength=\"5\",\n" +
    "              name=\"displayName\", ng-model=\"user.displayName\", placeholder='Display Name', \n" +
    "              required)\n" +
    "\n" +
    "\n" +
    ".modal-footer\n" +
    "  {{useremail}}\n" +
    "  a#toggle-signup-form.pull-left(ng-click=\"hideSignUp = !hideSignUp\", ng-href=\"#\").\n" +
    "    {{hideSignUp | iif : \"Not yet registered?\" : \"Already registered?\"}}\n" +
    "  span.\n" +
    "  button#submit-login.btn.btn-success(ng-click=\"submit()\" ng-disabled=\"login.$invalid || (!hideSignUp && signup.$invalid)\")\n" +
    "    {{hideSignUp | iif : \"Login\" : \"Sign Up\"}}\n" +
    "  button#close-login.btn.btn-default(ng-click=\"cancel()\") Cancel"
  );


  $templateCache.put('/partials/member.jade',
    "img(src=\"{{member.avatar}}\")"
  );


  $templateCache.put('/partials/members.jade',
    ".row\n" +
    "    .member-container\n" +
    "        .member(member, ng-repeat=\"member in members\",\n" +
    "            ng-class=\"{'col-lg-2 col-md-3 col-sm-4 col-xs-6':chat_state!='expanded', 'col-lg-3 col-md-4 col-sm-6':chat_state=='expanded'}\")\n" +
    "                "
  );


  $templateCache.put('/partials/room.jade',
    "\n" +
    "\n" +
    "\n" +
    "\n" +
    "//- .page-header\n" +
    "//-   fieldset\n" +
    "//-     legend {{room.name}}\n" +
    "//-     .row.clearfix\n" +
    "//-       .col-sm-6\n" +
    "//-         .panel(ng-class=\"getActivePanel('clients-chat')\", ng-click=\"setActivePanel('clients-chat')\")\n" +
    "//-           .panel-heading Clients/Chat\n" +
    "//-           .panel-body\n" +
    "//-             tabset(justified=\"true\")\n" +
    "//-               tab#clients-tab(ng-controller=\"ClientsCtrl\", heading=\"Clients\")\n" +
    "//-                 #clients\n" +
    "//-                   .row.options\n" +
    "//-                     .col-xs-12\n" +
    "//-                       button.btn.btn-primary.btn-sm.share-screen-to-all Share Screen\n" +
    "//-                         i.glyphicon.glyphicon-picture\n" +
    "//-                       button.btn.btn-primary.btn-sm.share-webcam-to-all Share Webcam\n" +
    "//-                         i.glyphicon.glyphicon-facetime-video\n" +
    "//-                   .row.clearfix\n" +
    "//-                     .col-md-4.col-sm-6.col-xs-3(ng-repeat=\"client in clients\")\n" +
    "//-                       .client(client resize)\n" +
    "\n" +
    "//-               tab#chat-tab(ng-controller=\"ChatCtrl\", heading=\"Chat\")\n" +
    "//-                 #chat\n" +
    "//-                   .panel(ng-class=\"getActivePanel('chat')\", \n" +
    "//-                           ng-click=\"setActivePanel('chat')\", \n" +
    "//-                           focus-on-click=\"input-chat-message\")\n" +
    "//-                     .panel-body\n" +
    "//-                       #chat-messages(update-scroll-position=\"chat.messages.length\")\n" +
    "//-                         .chat-message.clearfix(ng-repeat=\"message in chat.messages\", \n" +
    "//-                                                 delay-display=\"message\")\n" +
    "//-                           span.well.well-sm(ng-class-even=\"'own-msg'\").\n" +
    "//-                             <b>{{message.sender}}: </b>{{message.content}}\n" +
    "//-                     .panel-footer.no-padding\n" +
    "//-                       .row\n" +
    "//-                         form(name=\"chatMessage\", no-validate, \n" +
    "//-                               ng-submit=\"submitChatMessage()\")\n" +
    "//-                           .col-xs-10\n" +
    "//-                             input#input-chat-message.form-control(type=\"text\", \n" +
    "//-                               required, ng-model=\"chat.message\")\n" +
    "//-                           a#submit-chat-message.btn.col-xs-2(\n" +
    "//-                               ng-click=\"submitChatMessage()\", ng-href=\"#\",\n" +
    "//-                               ng-disabled=\"chatMessage.$invalid\", \n" +
    "//-                               focus-on-click=\"input-chat-message\")\n" +
    "//-                             i.icon-submit-chat-message.glyphicon.glyphicon-share-alt\n" +
    "\n" +
    "//-       .col-sm-6#notes(ng-controller=\"NotesCtrl\")\n" +
    "//-         .panel(ng-class=\"getActivePanel('notes')\", ng-click=\"setActivePanel('notes')\")\n" +
    "//-           .panel-heading.clearfix\n" +
    "//-             span Notes\n" +
    "//-             p#add-note.pull-right.well.well-sm.no-margin(ng-click=\"addNote()\") Add Note\n" +
    "//-               i.no-margin.glyphicon.glyphicon-file\n" +
    "//-           .panel-body\n" +
    "//-             tabset(adjust-width=\"room.notes.length\")\n" +
    "//-               tab(ng-repeat=\"note in room.notes\", heading=\"{{note.title}}\", \n" +
    "//-                 popover=\"{{note.title}}\", popover-trigger=\"mouseenter\")\n" +
    "//-                 .note\n" +
    "//-                   form.form-horizontal.clearfix(novalidate, name=\"note-form-{{$index}}\", method=\"post\")\n" +
    "//-                     .col-xs-12\n" +
    "//-                       h3\n" +
    "//-                         input.form-control(ng-model=\"note.title\")\n" +
    "//-                     .col-xs-12\n" +
    "//-                       textarea.form-control(ng-model=\"note.content\", rows=\"15\", \n" +
    "//-                         ui-tinymce=\"tinymceOptions\", name=\"test\")\n" +
    "//-                     .col-xs-12\n" +
    "//-                       .pull-right.controls\n" +
    "//-                         button.btn.btn-sm.btn-primary(alt=\"Download note\") Download \n" +
    "//-                           i.glyphicon.glyphicon-cloud-download.download-note\n" +
    "//-                         button.btn.btn-sm.btn-danger(ng-click=\"removeNote(title)\") Delete \n" +
    "//-                           i.glyphicon.glyphicon-trash.delete-note(alt=\"Delete note\")\n"
  );


  $templateCache.put('/partials/share.jade',
    ".heading.clearfix.controls\n" +
    "    .row\n" +
    "        .sorting.clearfix.col-xs-6(ng-class=\"{'ascending':controls.sorting.ascending}\")\n" +
    "            span Sort by:\n" +
    "            div(ng-class=\"{'active':controls.sorting.state=='name'}\", \n" +
    "                ng-click=\"setSortingState('name')\") Name\n" +
    "            div(ng-class=\"{'active':controls.sorting.state=='category'}\", \n" +
    "                ng-click=\"setSortingState('category')\") Category\n" +
    "            div(ng-class=\"{'active':controls.sorting.state=='author'}\", \n" +
    "                ng-click=\"setSortingState('author')\") Author\n" +
    "            div(ng-class=\"{'active':controls.sorting.state=='created'}\", \n" +
    "                ng-click=\"setSortingState('created')\") Date\n" +
    "            div(ng-class=\"{'active':controls.sorting.state=='size'}\", \n" +
    "                ng-click=\"setSortingState('size')\") Filesize\n" +
    "\n" +
    "        .layout.col-xs-6\n" +
    "            form(name=\"controlSearch\", no-validate)\n" +
    "                .control-input\n" +
    "                    input#searchString.form-control(type=\"text\", \n" +
    "                        required, ng-model=\"controls.searchString\",\n" +
    "                        placeholder=\"Type to search...\")\n" +
    "            span(ng-click=\"controls.layout='layout-icons'\",\n" +
    "                ng-class=\"{'active':controls.layout=='layout-icons'}\",\n" +
    "                popover-placement=\"bottom\", popover=\"Set Layout: Icons\",\n" +
    "                popover-trigger=\"mouseenter\")\n" +
    "                i.fa.fa-th\n" +
    "            span(ng-click=\"controls.layout='layout-list'\",\n" +
    "                ng-class=\"{'active':controls.layout=='layout-list'}\",\n" +
    "                popover-placement=\"bottom\", popover=\"Set Layout: List\",\n" +
    "                popover-trigger=\"mouseenter\")\n" +
    "                i.fa.fa-list-ul\n" +
    "\n" +
    "\n" +
    "\n" +
    "ul.items-container.clearfix.row(class=\"{{controls.layout}}\", fit-item-height=\"{{controls.layout}}\")\n" +
    "\n" +
    "    li(ng-class=\"{'col-xs-12 item-container':controls.layout=='layout-list', 'col-lg-2 col-md-3 col-sm-6':controls.layout=='layout-icons'&&chat_state!='expanded', 'col-lg-4 col-md-6 col-sm-12':controls.layout=='layout-icons'&&chat_state=='expanded'}\",\n" +
    "        ng-repeat=\"item in shared_items | filter:controls.searchString | orderBy:controls.sorting.state:controls.sorting.ascending\")\n" +
    "\n" +
    "\n" +
    "        .item-container(ng-if=\"controls.layout=='layout-icons'\")\n" +
    "            ng-include(src=\"item.templateUrl\")\n" +
    "\n" +
    "\n" +
    "        .row(ng-if=\"controls.layout=='layout-list'\", class=\"{{item.category}}\")\n" +
    "            .col-xs-1.category-icon(class=\"{{item.category}}\")\n" +
    "            .name(ng-class=\"{'col-xs-3':chat_state=='expanded', 'col-xs-2':chat_state!='expanded'}\")\n" +
    "                | {{item.name}}\n" +
    "            .author(ng-class=\"{'col-xs-4':chat_state=='expanded', 'col-xs-2':chat_state!='expanded'}\")\n" +
    "                | {{item.author}}\n" +
    "            .size.col-xs-1\n" +
    "                | {{item.size}}\n" +
    "            .created.col-xs-2(ng-show=\"chat_state!='expanded'\")\n" +
    "                | {{item.created}}\n" +
    "\n" +
    "            .item-controls.col-xs-3.clearfix(\n" +
    "                ng-class=\"{'col-xs-offset-1':chat_state!='expanded'}\")\n" +
    "                i.fa.fa-trash-o\n" +
    "                i.fa.fa-clipboard\n" +
    "                i.fa.fa-download(\n" +
    "                    ng-show=\"item.category=='note' || item.category=='file' || item.category=='code' || item.category=='screenshot'\")\n" +
    "                i.fa.fa-pencil(\n" +
    "                    ng-show=\"item.category=='note' || item.category=='code'\")\n" +
    "                i.fa.fa-eye(\n" +
    "                    ng-show=\"item.category=='shared-screen' || item.category=='shared-webcam' || item.category=='screenshot'\")"
  );


  $templateCache.put('/partials/spacelab.jade',
    "#banner.page-header\n" +
    "  .row\n" +
    "    .col-lg-6\n" +
    "      h1 Cyborg\n" +
    "      p.lead Jet black and electric blue\n" +
    "    .col-lg-6\n" +
    "      .bsa.well\n" +
    "        #bsap_1277971.bsarocks.bsap_c466df00a3cd5ee8568b5c4983b6bb19\n" +
    "//\n" +
    "   Navbar\n" +
    "        ==================================================\n" +
    ".bs-docs-section.clearfix\n" +
    "  .row\n" +
    "    .col-lg-12\n" +
    "      .page-header\n" +
    "        h1#navbar Navbar\n" +
    "      .bs-example\n" +
    "        .navbar.navbar-default\n" +
    "          .navbar-header\n" +
    "            button.navbar-toggle(type='button', data-toggle='collapse', data-target='.navbar-responsive-collapse')\n" +
    "              span.icon-bar\n" +
    "              span.icon-bar\n" +
    "              span.icon-bar\n" +
    "            a.navbar-brand(href='#') Brand\n" +
    "          .navbar-collapse.collapse.navbar-responsive-collapse\n" +
    "            ul.nav.navbar-nav\n" +
    "              li.active\n" +
    "                a(href='#') Active\n" +
    "              li\n" +
    "                a(href='#') Link\n" +
    "              li.dropdown\n" +
    "                a.dropdown-toggle(href='#', data-toggle='dropdown')\n" +
    "                  | Dropdown\n" +
    "                  b.caret\n" +
    "                ul.dropdown-menu\n" +
    "                  li\n" +
    "                    a(href='#') Action\n" +
    "                  li\n" +
    "                    a(href='#') Another action\n" +
    "                  li\n" +
    "                    a(href='#') Something else here\n" +
    "                  li.divider\n" +
    "                  li.dropdown-header Dropdown header\n" +
    "                  li\n" +
    "                    a(href='#') Separated link\n" +
    "                  li\n" +
    "                    a(href='#') One more separated link\n" +
    "            form.navbar-form.navbar-left\n" +
    "              input.form-control.col-lg-8(type='text', placeholder='Search')\n" +
    "            ul.nav.navbar-nav.navbar-right\n" +
    "              li\n" +
    "                a(href='#') Link\n" +
    "              li.dropdown\n" +
    "                a.dropdown-toggle(href='#', data-toggle='dropdown')\n" +
    "                  | Dropdown\n" +
    "                  b.caret\n" +
    "                ul.dropdown-menu\n" +
    "                  li\n" +
    "                    a(href='#') Action\n" +
    "                  li\n" +
    "                    a(href='#') Another action\n" +
    "                  li\n" +
    "                    a(href='#') Something else here\n" +
    "                  li.divider\n" +
    "                  li\n" +
    "                    a(href='#') Separated link\n" +
    "          //\n" +
    "             /.nav-collapse\n" +
    "        //\n" +
    "           /.navbar\n" +
    "        .navbar.navbar-inverse\n" +
    "          .navbar-header\n" +
    "            button.navbar-toggle(type='button', data-toggle='collapse', data-target='.navbar-inverse-collapse')\n" +
    "              span.icon-bar\n" +
    "              span.icon-bar\n" +
    "              span.icon-bar\n" +
    "            a.navbar-brand(href='#') Brand\n" +
    "          .navbar-collapse.collapse.navbar-inverse-collapse\n" +
    "            ul.nav.navbar-nav\n" +
    "              li.active\n" +
    "                a(href='#') Active\n" +
    "              li\n" +
    "                a(href='#') Link\n" +
    "              li.dropdown\n" +
    "                a.dropdown-toggle(href='#', data-toggle='dropdown')\n" +
    "                  | Dropdown\n" +
    "                  b.caret\n" +
    "                ul.dropdown-menu\n" +
    "                  li\n" +
    "                    a(href='#') Action\n" +
    "                  li\n" +
    "                    a(href='#') Another action\n" +
    "                  li\n" +
    "                    a(href='#') Something else here\n" +
    "                  li.divider\n" +
    "                  li.dropdown-header Dropdown header\n" +
    "                  li\n" +
    "                    a(href='#') Separated link\n" +
    "                  li\n" +
    "                    a(href='#') One more separated link\n" +
    "            form.navbar-form.navbar-left\n" +
    "              input.form-control.col-lg-8(type='text', placeholder='Search')\n" +
    "            ul.nav.navbar-nav.navbar-right\n" +
    "              li\n" +
    "                a(href='#') Link\n" +
    "              li.dropdown\n" +
    "                a.dropdown-toggle(href='#', data-toggle='dropdown')\n" +
    "                  | Dropdown\n" +
    "                  b.caret\n" +
    "                ul.dropdown-menu\n" +
    "                  li\n" +
    "                    a(href='#') Action\n" +
    "                  li\n" +
    "                    a(href='#') Another action\n" +
    "                  li\n" +
    "                    a(href='#') Something else here\n" +
    "                  li.divider\n" +
    "                  li\n" +
    "                    a(href='#') Separated link\n" +
    "          //\n" +
    "             /.nav-collapse\n" +
    "        //\n" +
    "           /.navbar\n" +
    "      //\n" +
    "         /example\n" +
    "//\n" +
    "   Buttons\n" +
    "        ==================================================\n" +
    ".bs-docs-section\n" +
    "  .page-header\n" +
    "    .row\n" +
    "      .col-lg-12\n" +
    "        h1#buttons Buttons\n" +
    "  .row\n" +
    "    .col-lg-6\n" +
    "      .bs-example\n" +
    "        p\n" +
    "          button.btn.btn-default(type='button') Default\n" +
    "          button.btn.btn-primary(type='button') Primary\n" +
    "          button.btn.btn-success(type='button') Success\n" +
    "          button.btn.btn-info(type='button') Info\n" +
    "          button.btn.btn-warning(type='button') Warning\n" +
    "          button.btn.btn-danger(type='button') Danger\n" +
    "          button.btn.btn-link(type='button') Link\n" +
    "      .bs-example\n" +
    "        p\n" +
    "          button.btn.btn-default.disabled(type='button') Default\n" +
    "          button.btn.btn-primary.disabled(type='button') Primary\n" +
    "          button.btn.btn-success.disabled(type='button') Success\n" +
    "          button.btn.btn-info.disabled(type='button') Info\n" +
    "          button.btn.btn-warning.disabled(type='button') Warning\n" +
    "          button.btn.btn-danger.disabled(type='button') Danger\n" +
    "          button.btn.btn-link.disabled(type='button') Link\n" +
    "      .bs-example(style='margin-bottom: 15px;')\n" +
    "        .btn-toolbar(style='margin: 0;')\n" +
    "          .btn-group\n" +
    "            button.btn.btn-default(type='button') Default\n" +
    "            button.btn.btn-default.dropdown-toggle(type='button', data-toggle='dropdown')\n" +
    "              span.caret\n" +
    "            ul.dropdown-menu\n" +
    "              li\n" +
    "                a(href='#') Action\n" +
    "              li\n" +
    "                a(href='#') Another action\n" +
    "              li\n" +
    "                a(href='#') Something else here\n" +
    "              li.divider\n" +
    "              li\n" +
    "                a(href='#') Separated link\n" +
    "          //\n" +
    "             /btn-group\n" +
    "          .btn-group\n" +
    "            button.btn.btn-primary(type='button') Primary\n" +
    "            button.btn.btn-primary.dropdown-toggle(type='button', data-toggle='dropdown')\n" +
    "              span.caret\n" +
    "            ul.dropdown-menu\n" +
    "              li\n" +
    "                a(href='#') Action\n" +
    "              li\n" +
    "                a(href='#') Another action\n" +
    "              li\n" +
    "                a(href='#') Something else here\n" +
    "              li.divider\n" +
    "              li\n" +
    "                a(href='#') Separated link\n" +
    "          //\n" +
    "             /btn-group\n" +
    "          .btn-group\n" +
    "            button.btn.btn-success(type='button') Success\n" +
    "            button.btn.btn-success.dropdown-toggle(type='button', data-toggle='dropdown')\n" +
    "              span.caret\n" +
    "            ul.dropdown-menu\n" +
    "              li\n" +
    "                a(href='#') Action\n" +
    "              li\n" +
    "                a(href='#') Another action\n" +
    "              li\n" +
    "                a(href='#') Something else here\n" +
    "              li.divider\n" +
    "              li\n" +
    "                a(href='#') Separated link\n" +
    "          //\n" +
    "             /btn-group\n" +
    "          .btn-group\n" +
    "            button.btn.btn-info(type='button') Info\n" +
    "            button.btn.btn-info.dropdown-toggle(type='button', data-toggle='dropdown')\n" +
    "              span.caret\n" +
    "            ul.dropdown-menu\n" +
    "              li\n" +
    "                a(href='#') Action\n" +
    "              li\n" +
    "                a(href='#') Another action\n" +
    "              li\n" +
    "                a(href='#') Something else here\n" +
    "              li.divider\n" +
    "              li\n" +
    "                a(href='#') Separated link\n" +
    "          //\n" +
    "             /btn-group\n" +
    "          .btn-group\n" +
    "            button.btn.btn-warning(type='button') Warning\n" +
    "            button.btn.btn-warning.dropdown-toggle(type='button', data-toggle='dropdown')\n" +
    "              span.caret\n" +
    "            ul.dropdown-menu\n" +
    "              li\n" +
    "                a(href='#') Action\n" +
    "              li\n" +
    "                a(href='#') Another action\n" +
    "              li\n" +
    "                a(href='#') Something else here\n" +
    "              li.divider\n" +
    "              li\n" +
    "                a(href='#') Separated link\n" +
    "          //\n" +
    "             /btn-group\n" +
    "        //\n" +
    "           /btn-toolbar\n" +
    "      .bs-example\n" +
    "        p\n" +
    "          button.btn.btn-primary.btn-lg(type='button') Large button\n" +
    "          button.btn.btn-primary(type='button') Default button\n" +
    "          button.btn.btn-primary.btn-sm(type='button') Small button\n" +
    "          button.btn.btn-primary.btn-xs(type='button') Mini button\n" +
    "    .col-lg-6\n" +
    "      .bs-example\n" +
    "        p\n" +
    "          button.btn.btn-default.btn-lg.btn-block(type='button') Block level button\n" +
    "      .bs-example(style='margin-bottom: 15px;')\n" +
    "        .btn-group.btn-group-justified\n" +
    "          a.btn.btn-default(href='#') Left\n" +
    "          a.btn.btn-default(href='#') Middle\n" +
    "          a.btn.btn-default(href='#') Right\n" +
    "      .bs-example(style='margin-bottom: 15px;')\n" +
    "        .btn-toolbar\n" +
    "          .btn-group\n" +
    "            button.btn.btn-default(type='button') 1\n" +
    "            button.btn.btn-default(type='button') 2\n" +
    "            button.btn.btn-default(type='button') 3\n" +
    "            button.btn.btn-default(type='button') 4\n" +
    "          .btn-group\n" +
    "            button.btn.btn-default(type='button') 5\n" +
    "            button.btn.btn-default(type='button') 6\n" +
    "            button.btn.btn-default(type='button') 7\n" +
    "          .btn-group\n" +
    "            button.btn.btn-default(type='button') 8\n" +
    "            .btn-group\n" +
    "              button.btn.btn-default.dropdown-toggle(type='button', data-toggle='dropdown')\n" +
    "                | Dropdown\n" +
    "                span.caret\n" +
    "              ul.dropdown-menu\n" +
    "                li\n" +
    "                  a(href='#') Dropdown link\n" +
    "                li\n" +
    "                  a(href='#') Dropdown link\n" +
    "                li\n" +
    "                  a(href='#') Dropdown link\n" +
    "      .bs-example\n" +
    "        .btn-group-vertical\n" +
    "          button.btn.btn-default(type='button') Button\n" +
    "          button.btn.btn-default(type='button') Button\n" +
    "          button.btn.btn-default(type='button') Button\n" +
    "          button.btn.btn-default(type='button') Button\n" +
    "//\n" +
    "   Typography\n" +
    "        ==================================================\n" +
    ".bs-docs-section\n" +
    "  .row\n" +
    "    .col-lg-12\n" +
    "      .page-header\n" +
    "        h1#type Typography\n" +
    "  //\n" +
    "     Headings\n" +
    "  .row\n" +
    "    .col-lg-4\n" +
    "      .bs-example.bs-example-type\n" +
    "        h1 Heading 1\n" +
    "        h2 Heading 2\n" +
    "        h3 Heading 3\n" +
    "        h4 Heading 4\n" +
    "        h5 Heading 5\n" +
    "        h6 Heading 6\n" +
    "      .bs-example\n" +
    "        p.lead Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor.\n" +
    "    .col-lg-4\n" +
    "      .bs-example\n" +
    "        h2 Example body text\n" +
    "        p\n" +
    "          | Nullam quis risus eget\n" +
    "          a(href='#') urna mollis ornare\n" +
    "          | vel eu leo. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Nullam id dolor id nibh ultricies vehicula.\n" +
    "        p\n" +
    "          small This line of text is meant to be treated as fine print.\n" +
    "        p\n" +
    "          | The following snippet of text is\n" +
    "          strong rendered as bold text\n" +
    "          | .\n" +
    "        p\n" +
    "          | The following snippet of text is\n" +
    "          em rendered as italicized text\n" +
    "          | .\n" +
    "        p\n" +
    "          | An abbreviation of the word attribute is\n" +
    "          abbr(title='attribute') attr\n" +
    "          | .\n" +
    "    .col-lg-4\n" +
    "      h2 Emphasis classes\n" +
    "      .bs-example\n" +
    "        p.text-muted Fusce dapibus, tellus ac cursus commodo, tortor mauris nibh.\n" +
    "        p.text-primary Nullam id dolor id nibh ultricies vehicula ut id elit.\n" +
    "        p.text-warning Etiam porta sem malesuada magna mollis euismod.\n" +
    "        p.text-danger Donec ullamcorper nulla non metus auctor fringilla.\n" +
    "        p.text-success Duis mollis, est non commodo luctus, nisi erat porttitor ligula.\n" +
    "        p.text-info Maecenas sed diam eget risus varius blandit sit amet non magna.\n" +
    "  //\n" +
    "     Blockquotes\n" +
    "  .row\n" +
    "    .col-lg-12\n" +
    "      h2#type-blockquotes Blockquotes\n" +
    "  .row\n" +
    "    .col-lg-6\n" +
    "      blockquote\n" +
    "        p\n" +
    "          | Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer posuere erat a ante.\n" +
    "        small\n" +
    "          | Someone famous in\n" +
    "          cite(title='Source Title') Source Title\n" +
    "    .col-lg-6\n" +
    "      blockquote.pull-right\n" +
    "        p\n" +
    "          | Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer posuere erat a ante.\n" +
    "        small\n" +
    "          | Someone famous in\n" +
    "          cite(title='Source Title') Source Title\n" +
    "//\n" +
    "   Tables\n" +
    "        ==================================================\n" +
    ".bs-docs-section\n" +
    "  .row\n" +
    "    .col-lg-12\n" +
    "      .page-header\n" +
    "        h1#tables Tables\n" +
    "      .bs-example.table-responsive\n" +
    "        table.table.table-striped.table-bordered.table-hover\n" +
    "          thead\n" +
    "            tr\n" +
    "              th #\n" +
    "              th Column heading\n" +
    "              th Column heading\n" +
    "              th Column heading\n" +
    "          tbody\n" +
    "            tr\n" +
    "              td 1\n" +
    "              td Column content\n" +
    "              td Column content\n" +
    "              td Column content\n" +
    "            tr\n" +
    "              td 2\n" +
    "              td Column content\n" +
    "              td Column content\n" +
    "              td Column content\n" +
    "            tr\n" +
    "              td 3\n" +
    "              td Column content\n" +
    "              td Column content\n" +
    "              td Column content\n" +
    "            tr.success\n" +
    "              td 4\n" +
    "              td Column content\n" +
    "              td Column content\n" +
    "              td Column content\n" +
    "            tr.danger\n" +
    "              td 5\n" +
    "              td Column content\n" +
    "              td Column content\n" +
    "              td Column content\n" +
    "            tr.warning\n" +
    "              td 6\n" +
    "              td Column content\n" +
    "              td Column content\n" +
    "              td Column content\n" +
    "            tr.active\n" +
    "              td 7\n" +
    "              td Column content\n" +
    "              td Column content\n" +
    "              td Column content\n" +
    "      //\n" +
    "         /example\n" +
    "//\n" +
    "   Forms\n" +
    "        ==================================================\n" +
    ".bs-docs-section\n" +
    "  .row\n" +
    "    .col-lg-12\n" +
    "      .page-header\n" +
    "        h1#forms Forms\n" +
    "  .row\n" +
    "    .col-lg-6\n" +
    "      .well\n" +
    "        form.bs-example.form-horizontal\n" +
    "          fieldset\n" +
    "            legend Legend\n" +
    "            .form-group\n" +
    "              label.col-lg-2.control-label(for='inputEmail') Email\n" +
    "              .col-lg-10\n" +
    "                input#inputEmail.form-control(type='text', placeholder='Email')\n" +
    "            .form-group\n" +
    "              label.col-lg-2.control-label(for='inputPassword') Password\n" +
    "              .col-lg-10\n" +
    "                input#inputPassword.form-control(type='password', placeholder='Password')\n" +
    "                .checkbox\n" +
    "                  label\n" +
    "                    input(type='checkbox')\n" +
    "                    | Checkbox\n" +
    "            .form-group\n" +
    "              label.col-lg-2.control-label(for='textArea') Textarea\n" +
    "              .col-lg-10\n" +
    "                textarea#textArea.form-control(rows='3')\n" +
    "                span.help-block\n" +
    "                  | A longer block of help text that breaks onto a new line and may extend beyond one line.\n" +
    "            .form-group\n" +
    "              label.col-lg-2.control-label Radios\n" +
    "              .col-lg-10\n" +
    "                .radio\n" +
    "                  label\n" +
    "                    input#optionsRadios1(type='radio', name='optionsRadios', value='option1', checked='')\n" +
    "                    | Option one is this\n" +
    "                .radio\n" +
    "                  label\n" +
    "                    input#optionsRadios2(type='radio', name='optionsRadios', value='option2')\n" +
    "                    | Option two can be something else\n" +
    "            .form-group\n" +
    "              label.col-lg-2.control-label(for='select') Selects\n" +
    "              .col-lg-10\n" +
    "                select#select.form-control\n" +
    "                  option 1\n" +
    "                  option 2\n" +
    "                  option 3\n" +
    "                  option 4\n" +
    "                  option 5\n" +
    "                br\n" +
    "                select.form-control(multiple='')\n" +
    "                  option 1\n" +
    "                  option 2\n" +
    "                  option 3\n" +
    "                  option 4\n" +
    "                  option 5\n" +
    "            .form-group\n" +
    "              .col-lg-10.col-lg-offset-2\n" +
    "                button.btn.btn-default Cancel\n" +
    "                button.btn.btn-primary(type='submit') Submit\n" +
    "    .col-lg-4.col-lg-offset-1\n" +
    "      form.bs-example\n" +
    "        .form-group\n" +
    "          label.control-label(for='focusedInput') Focused input\n" +
    "          input#focusedInput.form-control(type='text', value='This is focused...')\n" +
    "        .form-group\n" +
    "          label.control-label(for='disabledInput') Disabled input\n" +
    "          input#disabledInput.form-control(type='text', placeholder='Disabled input here...', disabled='')\n" +
    "        .form-group.has-warning\n" +
    "          label.control-label(for='inputWarning') Input warning\n" +
    "          input#inputWarning.form-control(type='text')\n" +
    "        .form-group.has-error\n" +
    "          label.control-label(for='inputError') Input error\n" +
    "          input#inputError.form-control(type='text')\n" +
    "        .form-group.has-success\n" +
    "          label.control-label(for='inputSuccess') Input success\n" +
    "          input#inputSuccess.form-control(type='text')\n" +
    "        .form-group\n" +
    "          label.control-label(for='inputLarge') Large input\n" +
    "          input#inputLarge.form-control.input-lg(type='text')\n" +
    "        .form-group\n" +
    "          label.control-label(for='inputDefault') Default input\n" +
    "          input#inputDefault.form-control(type='text')\n" +
    "        .form-group\n" +
    "          label.control-label(for='inputSmall') Small input\n" +
    "          input#inputSmall.form-control.input-sm(type='text')\n" +
    "        .form-group\n" +
    "          label.control-label Input addons\n" +
    "          .input-group\n" +
    "            span.input-group-addon $\n" +
    "            input.form-control(type='text')\n" +
    "            span.input-group-btn\n" +
    "              button.btn.btn-default(type='button') Button\n" +
    "//\n" +
    "   Navs\n" +
    "        ==================================================\n" +
    ".bs-docs-section\n" +
    "  .row\n" +
    "    .col-lg-12\n" +
    "      .page-header\n" +
    "        h1#nav Navs\n" +
    "  .row\n" +
    "    .col-lg-4\n" +
    "      h2#nav-tabs Tabs\n" +
    "      .bs-example\n" +
    "        ul.nav.nav-tabs(style='margin-bottom: 15px;')\n" +
    "          li.active\n" +
    "            a(href='#home', data-toggle='tab') Home\n" +
    "          li\n" +
    "            a(href='#profile', data-toggle='tab') Profile\n" +
    "          li.disabled\n" +
    "            a Disabled\n" +
    "          li.dropdown\n" +
    "            a.dropdown-toggle(data-toggle='dropdown', href='#')\n" +
    "              | Dropdown\n" +
    "              span.caret\n" +
    "            ul.dropdown-menu\n" +
    "              li\n" +
    "                a(href='#dropdown1', data-toggle='tab') Action\n" +
    "              li.divider\n" +
    "              li\n" +
    "                a(href='#dropdown2', data-toggle='tab') Another action\n" +
    "        #myTabContent.tab-content\n" +
    "          #home.tab-pane.fade.active.in\n" +
    "            p\n" +
    "              | Raw denim you probably haven't heard of them jean shorts Austin. Nesciunt tofu stumptown aliqua, retro synth master cleanse. Mustache cliche tempor, williamsburg carles vegan helvetica. Reprehenderit butcher retro keffiyeh dreamcatcher synth. Cosby sweater eu banh mi, qui irure terry richardson ex squid. Aliquip placeat salvia cillum iphone. Seitan aliquip quis cardigan american apparel, butcher voluptate nisi qui.\n" +
    "          #profile.tab-pane.fade\n" +
    "            p\n" +
    "              | Food truck fixie locavore, accusamus mcsweeney's marfa nulla single-origin coffee squid. Exercitation +1 labore velit, blog sartorial PBR leggings next level wes anderson artisan four loko farm-to-table craft beer twee. Qui photo booth letterpress, commodo enim craft beer mlkshk aliquip jean shorts ullamco ad vinyl cillum PBR. Homo nostrud organic, assumenda labore aesthetic magna delectus mollit.\n" +
    "          #dropdown1.tab-pane.fade\n" +
    "            p\n" +
    "              | Etsy mixtape wayfarers, ethical wes anderson tofu before they sold out mcsweeney's organic lomo retro fanny pack lo-fi farm-to-table readymade. Messenger bag gentrify pitchfork tattooed craft beer, iphone skateboard locavore carles etsy salvia banksy hoodie helvetica. DIY synth PBR banksy irony. Leggings gentrify squid 8-bit cred pitchfork.\n" +
    "          #dropdown2.tab-pane.fade\n" +
    "            p\n" +
    "              | Trust fund seitan letterpress, keytar raw denim keffiyeh etsy art party before they sold out master cleanse gluten-free squid scenester freegan cosby sweater. Fanny pack portland seitan DIY, art party locavore wolf cliche high life echo park Austin. Cred vinyl keffiyeh DIY salvia PBR, banh mi before they sold out farm-to-table VHS viral locavore cosby sweater.\n" +
    "    .col-lg-4\n" +
    "      h2#nav-pills Pills\n" +
    "      .bs-example\n" +
    "        ul.nav.nav-pills\n" +
    "          li.active\n" +
    "            a(href='#') Home\n" +
    "          li\n" +
    "            a(href='#') Profile\n" +
    "          li.disabled\n" +
    "            a(href='#') Disabled\n" +
    "          li.dropdown\n" +
    "            a.dropdown-toggle(data-toggle='dropdown', href='#')\n" +
    "              | Dropdown\n" +
    "              span.caret\n" +
    "            ul.dropdown-menu\n" +
    "              li\n" +
    "                a(href='#') Action\n" +
    "              li\n" +
    "                a(href='#') Another action\n" +
    "              li\n" +
    "                a(href='#') Something else here\n" +
    "              li.divider\n" +
    "              li\n" +
    "                a(href='#') Separated link\n" +
    "      br\n" +
    "      .bs-example\n" +
    "        ul.nav.nav-pills.nav-stacked(style='max-width: 300px;')\n" +
    "          li.active\n" +
    "            a(href='#') Home\n" +
    "          li\n" +
    "            a(href='#') Profile\n" +
    "          li.disabled\n" +
    "            a(href='#') Disabled\n" +
    "          li.dropdown\n" +
    "            a.dropdown-toggle(data-toggle='dropdown', href='#')\n" +
    "              | Dropdown\n" +
    "              span.caret\n" +
    "            ul.dropdown-menu\n" +
    "              li\n" +
    "                a(href='#') Action\n" +
    "              li\n" +
    "                a(href='#') Another action\n" +
    "              li\n" +
    "                a(href='#') Something else here\n" +
    "              li.divider\n" +
    "              li\n" +
    "                a(href='#') Separated link\n" +
    "    .col-lg-4\n" +
    "      h2#nav-breadcrumbs Breadcrumbs\n" +
    "      .bs-example\n" +
    "        ul.breadcrumb\n" +
    "          li.active Home\n" +
    "        ul.breadcrumb\n" +
    "          li\n" +
    "            a(href='#') Home\n" +
    "          li.active Library\n" +
    "        ul.breadcrumb(style='margin-bottom: 5px;')\n" +
    "          li\n" +
    "            a(href='#') Home\n" +
    "          li\n" +
    "            a(href='#') Library\n" +
    "          li.active Data\n" +
    "  .row\n" +
    "    .col-lg-4\n" +
    "      h2#pagination Pagination\n" +
    "      .bs-example\n" +
    "        ul.pagination\n" +
    "          li.disabled\n" +
    "            a(href='#') «\n" +
    "          li.active\n" +
    "            a(href='#') 1\n" +
    "          li\n" +
    "            a(href='#') 2\n" +
    "          li\n" +
    "            a(href='#') 3\n" +
    "          li\n" +
    "            a(href='#') 4\n" +
    "          li\n" +
    "            a(href='#') 5\n" +
    "          li\n" +
    "            a(href='#') »\n" +
    "        ul.pagination.pagination-lg\n" +
    "          li.disabled\n" +
    "            a(href='#') «\n" +
    "          li.active\n" +
    "            a(href='#') 1\n" +
    "          li\n" +
    "            a(href='#') 2\n" +
    "          li\n" +
    "            a(href='#') 3\n" +
    "          li\n" +
    "            a(href='#') »\n" +
    "        ul.pagination.pagination-sm\n" +
    "          li.disabled\n" +
    "            a(href='#') «\n" +
    "          li.active\n" +
    "            a(href='#') 1\n" +
    "          li\n" +
    "            a(href='#') 2\n" +
    "          li\n" +
    "            a(href='#') 3\n" +
    "          li\n" +
    "            a(href='#') 4\n" +
    "          li\n" +
    "            a(href='#') 5\n" +
    "          li\n" +
    "            a(href='#') »\n" +
    "    .col-lg-4\n" +
    "      h2#pager Pager\n" +
    "      .bs-example\n" +
    "        ul.pager\n" +
    "          li\n" +
    "            a(href='#') Previous\n" +
    "          li\n" +
    "            a(href='#') Next\n" +
    "      .bs-example\n" +
    "        ul.pager\n" +
    "          li.previous.disabled\n" +
    "            a(href='#') ← Older\n" +
    "          li.next\n" +
    "            a(href='#') Newer →\n" +
    "    .col-lg-4\n" +
    "//\n" +
    "   Indicators\n" +
    "        ==================================================\n" +
    ".bs-docs-section\n" +
    "  .row\n" +
    "    .col-lg-12\n" +
    "      .page-header\n" +
    "        h1#indicators Indicators\n" +
    "  .row\n" +
    "    .col-lg-12\n" +
    "      h2 Alerts\n" +
    "      .bs-example\n" +
    "        .alert.alert-dismissable.alert-warning\n" +
    "          button.close(type='button', data-dismiss='alert') ×\n" +
    "          h4 Warning!\n" +
    "          p\n" +
    "            | Best check yo self, you're not looking too good. Nulla vitae elit libero, a pharetra augue. Praesent commodo cursus magna,\n" +
    "            a.alert-link(href='#') vel scelerisque nisl consectetur et\n" +
    "            | .\n" +
    "  .row\n" +
    "    .col-lg-4\n" +
    "      .alert.alert-dismissable.alert-danger\n" +
    "        button.close(type='button', data-dismiss='alert') ×\n" +
    "        strong Oh snap!\n" +
    "        a.alert-link(href='#') Change a few things up\n" +
    "        | and try submitting again.\n" +
    "    .col-lg-4\n" +
    "      .alert.alert-dismissable.alert-success\n" +
    "        button.close(type='button', data-dismiss='alert') ×\n" +
    "        strong Well done!\n" +
    "        | You successfully read\n" +
    "        a.alert-link(href='#') this important alert message\n" +
    "        | .\n" +
    "    .col-lg-4\n" +
    "      .alert.alert-dismissable.alert-info\n" +
    "        button.close(type='button', data-dismiss='alert') ×\n" +
    "        strong Heads up!\n" +
    "        | This\n" +
    "        a.alert-link(href='#') alert needs your attention\n" +
    "        | , but it's not super important.\n" +
    "  .row\n" +
    "    .col-lg-4\n" +
    "      h2 Labels\n" +
    "      .bs-example(style='margin-bottom: 40px;')\n" +
    "        span.label.label-default Default\n" +
    "        span.label.label-primary Primary\n" +
    "        span.label.label-success Success\n" +
    "        span.label.label-warning Warning\n" +
    "        span.label.label-danger Danger\n" +
    "        span.label.label-info Info\n" +
    "    .col-lg-4\n" +
    "      h2 Badges\n" +
    "      .bs-example\n" +
    "        ul.nav.nav-pills\n" +
    "          li.active\n" +
    "            a(href='#')\n" +
    "              | Home\n" +
    "              span.badge 42\n" +
    "          li\n" +
    "            a(href='#')\n" +
    "              | Profile\n" +
    "              span.badge\n" +
    "          li\n" +
    "            a(href='#')\n" +
    "              | Messages\n" +
    "              span.badge 3\n" +
    "//\n" +
    "   Progress bars\n" +
    "        ==================================================\n" +
    ".bs-docs-section\n" +
    "  .row\n" +
    "    .col-lg-12\n" +
    "      .page-header\n" +
    "        h1#progress Progress bars\n" +
    "      h3#progress-basic Basic\n" +
    "      .bs-example\n" +
    "        .progress\n" +
    "          .progress-bar(style='width: 60%;')\n" +
    "      h3#progress-alternatives Contextual alternatives\n" +
    "      .bs-example\n" +
    "        .progress(style='margin-bottom: 9px;')\n" +
    "          .progress-bar.progress-bar-info(style='width: 20%;')\n" +
    "        .progress(style='margin-bottom: 9px;')\n" +
    "          .progress-bar.progress-bar-success(style='width: 40%;')\n" +
    "        .progress(style='margin-bottom: 9px;')\n" +
    "          .progress-bar.progress-bar-warning(style='width: 60%;')\n" +
    "        .progress\n" +
    "          .progress-bar.progress-bar-danger(style='width: 80%;')\n" +
    "      h3#progress-striped Striped\n" +
    "      .bs-example\n" +
    "        .progress.progress-striped(style='margin-bottom: 9px;')\n" +
    "          .progress-bar.progress-bar-info(style='width: 20%;')\n" +
    "        .progress.progress-striped(style='margin-bottom: 9px;')\n" +
    "          .progress-bar.progress-bar-success(style='width: 40%;')\n" +
    "        .progress.progress-striped(style='margin-bottom: 9px;')\n" +
    "          .progress-bar.progress-bar-warning(style='width: 60%;')\n" +
    "        .progress.progress-striped\n" +
    "          .progress-bar.progress-bar-danger(style='width: 80%;')\n" +
    "      h3#progress-animated Animated\n" +
    "      .bs-example\n" +
    "        .progress.progress-striped.active\n" +
    "          .progress-bar(style='width: 45%;')\n" +
    "      h3#progress-stacked Stacked\n" +
    "      .bs-example\n" +
    "        .progress\n" +
    "          .progress-bar.progress-bar-success(style='width: 35%;')\n" +
    "          .progress-bar.progress-bar-warning(style='width: 20%;')\n" +
    "          .progress-bar.progress-bar-danger(style='width: 10%;')\n" +
    "//\n" +
    "   Containers\n" +
    "        ==================================================\n" +
    ".bs-docs-section\n" +
    "  .row\n" +
    "    .col-lg-12\n" +
    "      .page-header\n" +
    "        h1#container Containers\n" +
    "      .bs-example\n" +
    "        .jumbotron\n" +
    "          h1 Jumbotron\n" +
    "          p\n" +
    "            | This is a simple hero unit, a simple jumbotron-style component for calling extra attention to featured content or information.\n" +
    "          p\n" +
    "            a.btn.btn-primary.btn-lg Learn more\n" +
    "  .row\n" +
    "    .col-lg-12\n" +
    "      h2 List groups\n" +
    "  .row\n" +
    "    .col-lg-4\n" +
    "      .bs-example\n" +
    "        ul.list-group\n" +
    "          li.list-group-item\n" +
    "            span.badge 14\n" +
    "            | Cras justo odio\n" +
    "          li.list-group-item\n" +
    "            span.badge 2\n" +
    "            | Dapibus ac facilisis in\n" +
    "          li.list-group-item\n" +
    "            span.badge 1\n" +
    "            | Morbi leo risus\n" +
    "    .col-lg-4\n" +
    "      .bs-example\n" +
    "        .list-group\n" +
    "          a.list-group-item.active(href='#')\n" +
    "            | Cras justo odio\n" +
    "          a.list-group-item(href='#')\n" +
    "            | Dapibus ac facilisis in\n" +
    "          a.list-group-item(href='#')\n" +
    "            | Morbi leo risus\n" +
    "    .col-lg-4\n" +
    "      .bs-example\n" +
    "        .list-group\n" +
    "          a.list-group-item(href='#')\n" +
    "            h4.list-group-item-heading List group item heading\n" +
    "            p.list-group-item-text\n" +
    "              | Donec id elit non mi porta gravida at eget metus. Maecenas sed diam eget risus varius blandit.\n" +
    "          a.list-group-item(href='#')\n" +
    "            h4.list-group-item-heading List group item heading\n" +
    "            p.list-group-item-text\n" +
    "              | Donec id elit non mi porta gravida at eget metus. Maecenas sed diam eget risus varius blandit.\n" +
    "  .row\n" +
    "    .col-lg-12\n" +
    "      h2 Panels\n" +
    "  .row\n" +
    "    .col-lg-4\n" +
    "      .panel.panel-default\n" +
    "        .panel-body\n" +
    "          | Basic panel\n" +
    "      .panel.panel-default\n" +
    "        .panel-heading Panel heading\n" +
    "        .panel-body\n" +
    "          | Panel content\n" +
    "      .panel.panel-default\n" +
    "        .panel-body\n" +
    "          | Panel content\n" +
    "        .panel-footer Panel footer\n" +
    "    .col-lg-4\n" +
    "      .panel.panel-primary\n" +
    "        .panel-heading\n" +
    "          h3.panel-title Panel primary\n" +
    "        .panel-body\n" +
    "          | Panel content\n" +
    "      .panel.panel-success\n" +
    "        .panel-heading\n" +
    "          h3.panel-title Panel success\n" +
    "        .panel-body\n" +
    "          | Panel content\n" +
    "      .panel.panel-warning\n" +
    "        .panel-heading\n" +
    "          h3.panel-title Panel warning\n" +
    "        .panel-body\n" +
    "          | Panel content\n" +
    "    .col-lg-4\n" +
    "      .panel.panel-danger\n" +
    "        .panel-heading\n" +
    "          h3.panel-title Panel danger\n" +
    "        .panel-body\n" +
    "          | Panel content\n" +
    "      .panel.panel-info\n" +
    "        .panel-heading\n" +
    "          h3.panel-title Panel info\n" +
    "        .panel-body\n" +
    "          | Panel content\n" +
    "  .row\n" +
    "    .col-lg-12\n" +
    "      h2 Wells\n" +
    "  .row\n" +
    "    .col-lg-4\n" +
    "      .well\n" +
    "        | Look, I'm in a well!\n" +
    "    .col-lg-4\n" +
    "      .well.well-sm\n" +
    "        | Look, I'm in a small well!\n" +
    "    .col-lg-4\n" +
    "      .well.well-lg\n" +
    "        | Look, I'm in a large well!\n"
  );


  $templateCache.put('/partials/test.jade',
    ".test test\n"
  );

}]);
