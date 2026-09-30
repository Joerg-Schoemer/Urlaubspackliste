//
//  AktivitaetenAuswahl.swift
//  Urlaubspackliste
//
//  Created by Jörg Schömer on 19.09.26.
//


import SwiftUI

/// Mehrfachauswahl der Aktivitäten einer Reise.
///
/// Picker scheidet hier aus: er ist auf sich gegenseitig ausschließende Werte festgelegt.
/// Die Zeilen sind deshalb Buttons mit Häkchen, optisch aber wie ein Picker im inline-Stil.
struct AktivitaetenAuswahl: View {
    let verfuegbare: [String]
    @Binding var ausgewaehlte: [String]

    var body: some View {
        ForEach(verfuegbare, id: \.self) { aktivitaet in
            Button {
                umschalten(aktivitaet)
            } label: {
                HStack {
                    Text(aktivitaet)
                        .foregroundStyle(.primary)
                    Spacer()
                    if ausgewaehlte.contains(aktivitaet) {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.tint)
                    }
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(ausgewaehlte.contains(aktivitaet) ? .isSelected : [])
        }
    }

    private func umschalten(_ aktivitaet: String) {
        if let index = ausgewaehlte.firstIndex(of: aktivitaet) {
            ausgewaehlte.remove(at: index)
        } else {
            ausgewaehlte.append(aktivitaet)
        }
    }
}

#Preview {
    @Previewable @State var ausgewaehlte = ["Wandern"]

    return Form {
        Section("Aktivität") {
            AktivitaetenAuswahl(
                verfuegbare: ["Camping", "Ski", "Strand", "Wandern"],
                ausgewaehlte: $ausgewaehlte
            )
        }
    }
}
