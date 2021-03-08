//
//  MovieCell.swift
//  MovieInformation
//
//  Created by boreum yoon on 2021/03/05.
//

import UIKit

class MovieCell: UITableViewCell {
    @IBOutlet weak var thumbnail: UIImageView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblGenre: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
