//
//  PaymentService.swift
//  lab_swift
//
//  Created by Екатерина Берендюгина on 06.03.2026.
//
protocol PaymentService {
    func pay(amount: Double) -> Result<Void,Error>;
}
