//
//  PersonAuswahlView.swift
//  Urlaubspackliste
//
//  Created by Jörg Schömer on 06.09.26.
//


import SwiftUI

struct PersonAuswahlView: View {
    let personen: [Person]
    let onAuswahl: (Person) -> Void
    
    var body: some View {
        NavigationStack {
            List(personen) { person in
                Button {
                    onAuswahl(person)
                } label: {
                    Text(person.name)
                }
            }
            .navigationTitle("Wer bist du?")
        }
    }
}