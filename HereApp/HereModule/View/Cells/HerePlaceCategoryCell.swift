//
//  HerePlaceCategoryCell.swift
//  HereApp
//
//  Created by Maria Holubieva on 09.11.2019.
//  Copyright © 2019 Maria Holubieva. All rights reserved.
//

import UIKit

class HerePlaceCategoryCell: UITableViewCell {

    @IBOutlet weak var labelName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        labelName.text = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        labelName.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        accessoryType = selected ? .checkmark : .none
    }

}
