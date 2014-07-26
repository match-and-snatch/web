namespace :billing do
  task cycle: :environment do
    Billing::ChargeJob.perform
  end

  task duplicates: :environment do
    User.all.each do |user|
      tuids = user.subscriptions.map(&:target_user_id)
      if tuids != tuids.uniq
        puts "#{user.id} - #{user.email}"
        puts tuids.inspect
        puts '==========='
      end
    end
  end

  task fix: :environment do
    subscriptions = Subscription.where(id: [2, 26, 62, 63, 144, 187, 335, 336, 337, 338, 339, 340, 341, 342, 343, 344, 345, 346, 347, 348, 349, 350, 352, 353, 354, 355, 356, 357, 359, 360, 361, 362, 363, 364, 366, 367, 368, 369, 370, 371, 372, 373, 374, 375, 376, 377, 378, 379, 380, 381, 382, 383, 384, 385, 386, 387, 388, 389, 390, 391, 392, 393, 394, 395, 396, 397, 398, 399, 400, 401, 402, 403, 404, 405, 406, 407, 409, 410, 411, 412, 413, 414, 415, 417, 418, 419, 420, 421, 422, 423, 424, 426, 427, 428, 429, 430, 431, 432, 433, 434, 435, 436, 437, 438, 439, 441, 442, 443, 445, 446, 447, 448, 449, 450, 451, 452, 453, 454, 455, 456, 457, 458, 459, 460, 461, 462, 463, 464, 465, 467, 468, 469, 470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492, 493, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523, 524, 525, 526, 528, 529, 530, 531, 532, 533, 535, 536, 538, 540, 541, 542, 543, 544, 545, 546, 547, 548, 549, 550, 551, 552, 553, 554, 555, 556, 557, 558, 559, 560, 561, 563, 564, 565, 566, 567, 568, 569, 570, 571, 572, 573, 574, 575, 576, 577, 578, 579, 581, 582, 583, 584, 585, 586, 587, 588, 589, 590, 591, 592, 593, 594, 595, 596, 597, 598, 599, 600, 602, 603, 604, 605, 606, 607, 608, 609, 611, 612, 613, 614, 615, 616, 617, 618, 619, 620, 621, 622, 623, 624, 625, 626, 627, 629, 631, 632, 633, 634, 635, 636, 637, 638, 639, 640, 641, 642, 643, 644, 645, 646, 648, 649, 650, 651, 652, 653, 654, 655, 656, 658, 659, 660, 661, 662, 663, 664, 666, 667, 668, 669, 670, 671, 672, 673, 674, 675, 676, 677, 678, 679, 680, 681, 682, 683, 684, 819, 1050, 1070, 1096, 1109, 1116, 1182, 1183, 1184, 1185, 1186, 1187, 1188, 1189, 1190, 1191, 1192, 1195, 1196, 1199, 1200, 1201, 1202, 1203, 1204, 1206, 1207, 1208, 1209, 1210, 1211, 1212, 1213, 1214, 1215, 1216, 1217, 1218, 1219, 1220, 1221, 1222, 1223, 1224, 1225, 1226, 1227, 1230, 1231, 1232, 1233, 1234, 1235, 1236, 1237, 1238, 1239, 1240, 1241, 1242, 1243, 1244, 1245, 1246, 1247, 1248, 1250, 1251, 1252, 1254, 1255, 1256, 1257, 1259, 1260, 1261])
    subscriptions.find_each do |subscription|
      month_created = subscription.created_at.month
      puts '================================================================'
      puts [subscription.id, subscription.created_at.to_s(:long), subscription.charged_at.to_s(:long)].inspect

      if month_created == 4
        subscription.charged_at = subscription.created_at + 2.months
      elsif month_created == 5
        subscription.charged_at = subscription.created_at + 1.month
      elsif month_created == 6
        subscription.charged_at = subscription.created_at
      elsif month_created == 7
        subscription.charged_at = subscription.created_at
      end
      subscription.save! rescue puts "failed: #{subscription.id}"
      puts [subscription.id, subscription.created_at.to_s(:long), subscription.charged_at.to_s(:long)].inspect
      puts '================================================================'
    end
  end
end
